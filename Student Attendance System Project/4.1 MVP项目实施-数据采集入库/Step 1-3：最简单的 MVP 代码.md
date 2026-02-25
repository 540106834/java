# **最简单的 MVP 思路**
不纠结 Spring 的机制，只看“数据怎么流动”。


## 1️ MVP 本质

你现在做的事情，可以抽象成 3 个步骤：

1. **接收数据**

   * HTTP POST 一条报文（curl 发过来）
   * 不关心协议复杂性，只是字符串

2. **入库 Raw**

   * 从报文里提取 `device_sn` 和 `sn`（幂等关键）
   * 连同报文原文 `raw_payload` 存进 MySQL `attendance_raw` 表
   * `parsed = 0`，等下解析

3. **验证**

   * 查一下 `attendance_raw` 表，确认数据真的进去了

---

## 2️ 最简化的代码结构

如果去掉 DTO + Hibernate，只用 **JdbcTemplate**，整个流程可能就 3 个文件：

### Controller（接收报文）

```java
package com.jinshaoyong.attendance.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.jinshaoyong.attendance.service.RawService;

@RestController
@RequestMapping("/api/raw")
public class DeviceMockController {

    @Autowired
    private RawService rawService;

    @PostMapping("/upload")
    public String upload(@RequestBody String payload) {

        if (payload == null || payload.length() < 50) {
            return "INVALID_PAYLOAD";
        }
        if (!payload.startsWith("DIRM01")) {
            return "INVALID_HEADER";
        }

        // ===== 固定位置截取（基于你定义的 F09 报文结构） =====
        // DIRM01(6)
        // 长度(4)
        // 功能号(4)
        // SN(2)
        // deviceSn(15)

        String sn = payload.substring(14, 16); // 2位序列号
        String deviceSn = payload.substring(16, 31); // 15位设备号

        rawService.save(deviceSn, sn, payload);

        return "OK";
    }

    @GetMapping("/ping")
    public String ping() {
        return "status: 200 ok";
    }

}
```

### Service（存数据库）

```java
package com.jinshaoyong.attendance.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

@Service
public class RawService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void save(String deviceSn, String sn, String rawPayload) {

        // 先查是否重复（幂等）
        // String checkSql = "SELECT COUNT(*) FROM attendance_raw WHERE device_sn=? AND
        // sn=?";
        // Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class,
        // deviceSn, sn);

        // if (count != null && count > 0) {
        // System.out.println("重复数据，跳过");
        // return;
        // }
        String payloadHash = DigestUtils.md5DigestAsHex(rawPayload.getBytes());
        String sql = """
                INSERT INTO attendance_raw
                (device_sn, sn, raw_payload, payload_hash, parsed, received_at)
                VALUES (?, ?, ?, ?, 0, NOW())
                """;
        try {
            jdbcTemplate.update(sql, deviceSn, sn, rawPayload, payloadHash);
            System.out.println("Raw 数据入库成功");
        } catch (DuplicateKeyException e) {
            System.out.println("重复数据，忽略");
        }

        // jdbcTemplate.update(sql, deviceSn, sn, rawPayload);
        // System.out.println("Raw 数据入库成功");
    }
}
```

### curl 测试

```bash
#!/bin/bash

# ===== 固定字段 =====
HEADER="DIRM01"
LENGTH="0032"
FUNC="0900"
DEVICE_SN="860123456789012"
CHECKSUM="0A"

# ===== 循环次数 =====
COUNT=20   # 你可以改成 100 / 1000

echo "开始生成 $COUNT 条考勤数据..."
echo "--------------------------------"

for ((i=1; i<=COUNT; i++))
do
  # SN 两位递增（01~99循环）
  SN=$(printf "%02d" $((i % 100)))

  # 生成8位随机卡号
  CARD_NO=$(printf "%08d" $((RANDOM % 100000000)))

  # 当前时间 yyyyMMddHHmmss
  EVENT_TIME=$(date +"%Y%m%d%H%M%S")

  # 进出类型随机 0 或 1
  EVENT_TYPE=$((RANDOM % 2))

  # 拼接报文
  PAYLOAD="${HEADER}${LENGTH}${FUNC}${SN}${DEVICE_SN}${CARD_NO}${EVENT_TIME}${EVENT_TYPE}${CHECKSUM}"

  echo "[$i] $PAYLOAD"

  # 发送
  curl -s -X POST http://192.168.11.171:8080/api/raw/upload \
  -H "Content-Type: text/plain" \
  -d "$PAYLOAD" > /dev/null

  # 可选：每条间隔 0.2 秒（模拟真实设备）
  sleep 0.2
done

echo "--------------------------------"
echo "发送完成"
```

✅ 这个流程不需要 DTO、Hibernate、Spring Data JPA，**最直观地把报文写进 Raw 表**

---

## 3️ 理解方式

* **Controller** → 收到数据
* **Service** → 数据存库
* **Raw 表** → 临时存储，Parser 后续再解析

> 你现在只要理解这三个环节就够了
> Spring 的自动注入、DTO、Hibernate 都是“优化和规范”，不影响你 MVP 能跑通

---

如果你愿意，我可以帮你画一个 **MVP 流程图**，用箭头表示报文从 curl → Controller → Service → MySQL Raw 表，视觉上非常直观，理解 Spring 逻辑就简单了。

你希望我画吗？


好，我们就沿着这个思路，把**MVP 流程 + 后续扩展点**可视化，帮你理清“现在够用 / 以后再加”。

---

## 1️ MVP 流程图（核心 30%）

```text
[设备模拟数据]
       |
       v
[curl / HTTP POST]
       |
       v
[Controller: /device/upload]
       |
       v
[Service: RawService.save()]
       |
       v
[MySQL: attendance_raw 表]
```

* **每一步的意义**：

  1. curl → Controller：验证通道是否通
  2. Controller → Service：分离逻辑，方便扩展 Parser
  3. Service → Raw 表：Raw 数据“记忆现实”，是后续解析的基础

* ✅ MVP 成功标志：`attendance_raw` 表里能看到你的报文

---

## 2️ Raw 解析阶段（下一步）

```text
[attendance_raw (parsed=0)]
       |
       v
[Parser: 拆 card_no / event_time / event_type]
       |
       v
[attendance 表插入记录]
       |
       v
[attendance_raw (parsed=1)]
```

* Parser 可以**离线 / 定时 / 手动**跑
* 拆解规则固定（索引截取 card_no、event_time、event_type）
* 解析失败可写 error_msg

---

## 3️ 后续复杂扩展点（现在不用管，但标记）

| 扩展点                  | 价值          | 加入条件                   |
| -------------------- | ----------- | ---------------------- |
| **Hibernate / JPA**  | 自动对象映射、查询方便 | 数据量大、表关系多              |
| **DTO + Validation** | 接口结构化 + 校验  | 设备类型多，报文字段多            |
| **Redis 缓存**         | 提升读取性能      | 高并发查询 Raw 或 Attendance |
| **Kafka / MQ**       | 异步/解耦       | 多服务、多节点、多设备同时入库        |
| **Security / Auth**  | 接口保护        | 系统上线给真实设备用             |
| **Netty / TCP 通信**   | 性能优化        | HTTP 无法满足高并发或原生协议需求    |
| **多表多业务逻辑**          | 扩展功能        | 上报不止考勤，还要其他设备数据        |

>  关键点：**MVP 完成 + Raw 表可入库 = 学够了**
> 其他复杂东西都是“优化和扩展”，可以按需再加

---

## 4️ 学习建议

1. **先把 Raw 流程熟练**：curl → Controller → Service → MySQL
2. **理解 Parser 思路**：把 Raw 解析成 Attendance
3. **等 MVP 成功**，再看 Hibernate、DTO、MQ、Netty 等高级内容

---

我可以帮你画一张 **可视化流程图**，把：

* MVP 流程
* Parser 流程
* 后续扩展点

都放在一张图里，箭头清楚标出数据流向，让你一眼知道“现在学够了、后面加什么才有意义”。

你希望我画吗？
