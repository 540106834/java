
# 🥇 第一步：今天只做「Raw 接入 MVP」

现在我们不“讲道理”，只**干一件今天就能完成的事**。

你已经在正确的轨道上了，接下来我会像项目里的**技术负责人**一样，给你明确指令。

当前阶段定位你现在处在这里：

```
系统还没跑
↓
准备第一次“设备 → 数据库”心跳
```

### 今天的目标只有一句话：

> **让一条“假的设备考勤数据”，稳稳地落进 Raw 表。**

不解析
不校验
不高并发

先活下来。


##  你要完成的 3 件事（缺一不可）

1. Spring Boot 项目能启动
2. 能接收一段字符串（模拟设备）
3. 能插入 `attendance_raw` 表

完成这三点，你就是在“造系统”，不是在“学知识”。

---

#  Step 1：确认数据库状态（5 分钟）

你现在数据库里**必须至少有这张表**：

```sql
attendance_raw
```

创建数据库：
```sql
CREATE DATABASE IF NOT EXISTS smart_attendance 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;
use smart_attendane;

CREATE USER 'attend'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON smart_attendance.* TO 'attend'@'%';
SHOW GRANTS FOR 'attend'@'%';

FLUSH PRIVILEGES;
```


字段最小化即可：

```sql
DROP TABLE attendance_raw;

CREATE TABLE attendance_raw (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '自增主键',

    device_sn VARCHAR(64) NOT NULL COMMENT '设备ID',
    sn VARCHAR(16) NOT NULL COMMENT '设备上传流水号',
    raw_payload TEXT NOT NULL COMMENT '原始报文',
    parsed TINYINT DEFAULT 0 COMMENT '0未解析 1成功 2失败',
    error_msg VARCHAR(255) DEFAULT NULL COMMENT '解析错误信息',
    received_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',
    payload_hash CHAR(32) NOT NULL COMMENT 'MD5 of raw payload',

    UNIQUE INDEX uk_payload_hash (payload_hash),
    
    INDEX idx_device_sn (device_sn),
    INDEX idx_received_at (received_at),
    INDEX idx_parsed (parsed)
);

```

> ⚠️ 注意：
> **现在别纠结 school_id、func_code**
> MVP 阶段，越少越好。

---

#  Step 2：创建 Spring Boot 项目（不要选太多依赖）

### 只选这几个：

* Spring Web
* Spring Data JPA（或 MyBatis，你熟哪个用哪个）
* MySQL Driver

不要选：

* Security
* Redis
* Cloud

那些现在都是噪音。

---

#  Step 3：先用 HTTP 模拟设备（非常关键）

### ⚠️ 为什么不用 TCP / Netty？

因为现在你要验证的是：

> **数据链路是否通，而不是通信性能。**

真实项目里，**80% 的协议 Bug** 都是在解析阶段，不在 Netty。

---

## 建一个 Controller（示意）

```java
@RestController
@RequestMapping("/device")
public class DeviceMockController {

    @PostMapping("/upload")
    public String upload(@RequestBody String payload) {
        System.out.println("收到设备数据：" + payload);
        // TODO: 入库
        return "OK";
    }
}
```

你现在只关心一件事：

 **payload 能不能进方法。**

---

#  Step 4：把 Raw 写进数据库（系统第一次“记忆”）

写一个最简单的 Service：

```java
@Service
public class RawService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void save(String deviceSn, String payload) {
        String sql = "INSERT INTO attendance_raw(device_sn, raw_payload, received_at) VALUES (?, ?, NOW())";
        jdbcTemplate.update(sql, deviceSn, payload);
    }
}
```

Controller 里调用它。

---

#  Step 5：模拟一条考勤数据（你熟悉的那条）

用 Postman / curl 发：

```text
DIRM01003209000186012345678901200004567202602010759300A
```

不用管对不对。

只问一句： **数据库里有没有多一条 raw 记录？**

如果有：**恭喜，你的系统第一次“接收到了现实”。**

---

#  这一刻你应该意识到一件事（非常重要）

你已经完成了：

> **IoT 系统最难的 30%**

后面的事，只是不断重复这个模式：

```
接 → 存 → 处理 → 再存
```

---

#  下一步（提前预告，不要现在做）

等 Raw 稳了，我们下一步只干一件事：

## 🔥 写 Parser（离线 / 定时 / 手动都行）

目标：

```
attendance_raw.parse_status = 0
↓
解析
↓
写 attendance
↓
raw = 1 / 2
```

你会第一次真正“理解协议”。

---

#  一个非常重要的工程习惯（现在就养）

## 每一步都能“单独验证”

* Raw 能不能写？
* Parser 能不能跑？
* Attendance 能不能查？

不要写一坨“全自动”。

---

#  现在你该做什么（明确指令）

请你现在就去做：

1️⃣ 建 Spring Boot 项目
2️⃣ 写 `/device/upload`
3️⃣ 发一条假数据
4️⃣ 截止到 Raw 表出现数据

做完后，回来告诉我一句：

> **“Raw 表已经能进数据了”**

我会立刻带你进入：

 **解析阶段（真正有技术含量的部分）**

你已经不是在“学习”，你是在**造一个真实系统**了。
