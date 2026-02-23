
# 🥉 第三步：让第一条 Raw 数据进库

太棒，这一步是**系统第一次真正“活”起来**的瞬间。
我们要让设备数据顺利进入数据库的 **Raw 表**。不追求性能，只求**可跑、可验证、可追溯**。

下面给你**从零开始的落地步骤**。

##  目标

1. Spring Boot 能启动
2. 能接收设备数据（HTTP 模拟）
3. 数据写进 `attendance_raw` 表
4. Raw 表里能看到记录

---

# 一、创建 Spring Boot 项目

### 1️ 最小依赖（Maven）

```xml
<dependencies>
    <!-- Spring Web 用来搭建 HTTP 接口 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- MySQL 驱动 -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
    </dependency>

    <!-- JDBC 或 JPA（这里用 JDBC 简单演示） -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
</dependencies>
```

### 2️ 配置数据库连接（application.properties）

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/smart_attendance?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=你的密码
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.show-sql=true
```

> ⚠️ 这里假设你 MySQL 已经建好 `smart_attendance` 数据库。

```sql
CREATE TABLE attendance_raw (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '自增主键',

    device_sn VARCHAR(64) NOT NULL COMMENT '设备ID / 序列号',
    card_no VARCHAR(32) NOT NULL COMMENT '学生卡号',
    event_time DATETIME NOT NULL COMMENT '打卡时间',
    event_type TINYINT NOT NULL COMMENT '0进校 1离校',
    sn VARCHAR(16) NOT NULL COMMENT '设备上传流水号',

    parsed TINYINT DEFAULT 0 COMMENT '是否解析，0未解析 1已解析',
    received_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',

    UNIQUE KEY uk_device_sn (device_sn, sn),
    INDEX idx_card_time (card_no, event_time)
);
```
---
原始数据：
```bash
设备ID: 860123456789012
卡号:   00004567
时间:   20260201075930
类型:   0 (进校)
SN:     0001
功能号: 09 (F09上传)
```

1️. DTO 类 RawDataDTO.java:
```java
package com.jinshaoyong.attendance.dto;

public class RawDataDTO {

    private String deviceSn;
    private String cardNo;
    private String eventTime; // 格式: "yyyy-MM-dd HH:mm:ss"
    private int eventType;    // 0进校 1离校
    private String sn;

    public String getDeviceSn() { return deviceSn; }
    public void setDeviceSn(String deviceSn) { this.deviceSn = deviceSn; }

    public String getCardNo() { return cardNo; }
    public void setCardNo(String cardNo) { this.cardNo = cardNo; }

    public String getEventTime() { return eventTime; }
    public void setEventTime(String eventTime) { this.eventTime = eventTime; }

    public int getEventType() { return eventType; }
    public void setEventType(int eventType) { this.eventType = eventType; }

    public String getSn() { return sn; }
    public void setSn(String sn) { this.sn = sn; }
}

```
2️. Service 类 AttendanceRawService.java
```java
package com.jsy.attendance.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class AttendanceRawService {

    private final JdbcTemplate jdbcTemplate;

    public AttendanceRawService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void saveRawData(String deviceSn, String cardNo, LocalDateTime eventTime, int eventType, String sn) {
        String sql = "INSERT INTO attendance_raw(device_sn, card_no, event_time, event_type, sn, parsed, received_at) " +
                     "VALUES (?, ?, ?, ?, ?, 0, NOW())";
        jdbcTemplate.update(sql, deviceSn, cardNo, eventTime, eventType, sn);
        System.out.println("Raw 数据已写入: " + deviceSn + " -> " + cardNo + " -> " + eventTime);
    }
}

```

3️ Controller 类 AttendanceRawController.java
```java
package com.example.attendance.controller;

import com.example.attendance.dto.RawDataDTO;
import com.example.attendance.service.AttendanceRawService;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/raw")
public class AttendanceRawController {

    private final AttendanceRawService rawService;
    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public AttendanceRawController(AttendanceRawService rawService) {
        this.rawService = rawService;
    }

    /**
     * 测试接口
     */
    @GetMapping("/ping")
    public String ping() {
        return "ok";
    }

    /**
     * 接收原始打卡数据
     */
    @PostMapping("/save")
    public String saveRaw(@RequestBody RawDataDTO dto) {
        try {
            LocalDateTime eventTime = LocalDateTime.parse(dto.getEventTime(), formatter);
            rawService.saveRawData(dto.getDeviceSn(), dto.getCardNo(), eventTime, dto.getEventType(), dto.getSn());
            return "ok";
        } catch (Exception e) {
            e.printStackTrace();
            return "error: " + e.getMessage();
        }
    }
}

```


# 4️ 测试 

1️ 启动 Spring Boot

确认控制台启动没有报错。

2️ 用 Postman 或 curl 发送请求

```bash
curl -X GET http://localhost:8080/api/raw/ping
```

```bash
curl -X POST http://localhost:8080/api/raw/save \
  -H "Content-Type: application/json" \
  -d '{
        "deviceSn": "DEV001",
        "cardNo": "CARD001",
        "eventTime": "2026-02-01 08:10:00",
        "eventType": 0,
        "sn": "SN001"
      }'

```


3️ 检查 Raw 表

```sql
SELECT * FROM attendance_raw;
```

你应该能看到：

| id | device_sn       | raw_payload                                             | received_at         | parse_status |
| -- | --------------- | ------------------------------------------------------- | ------------------- | ------------ |
| 1  | 860123456789012 | DIRM01003209000186012345678901200004567202602010759300A | 2026-02-01 08:00:00 | 0            |

>  恭喜！系统第一次呼吸。Raw 数据成功入库。

---

# 五、工程小提示

1. 先用 HTTP 模拟，**不要急着上 Netty**
2. Raw 表是黑匣子，不做解析没关系
3. 现在关键是：**设备数据流通链路可用**
4. 后续 Parser、Attendance 写入、去重再做

---

#  下一步

当 Raw 表能稳定接收数据后，我们就可以进入：

## **第四步：解析 Raw → 写 Attendance（协议解析逻辑）**

* 把设备报文拆字段
* 对应到 student / device / school
* 写入 attendance
* 标记 raw.parse_status = 1 或 2

这样你的系统就形成了完整闭环。

---

我可以帮你直接写一个 **最小解析器示例**，把刚刚的 Raw 数据解析成 **attendance 记录**，落库验证。

你希望我现在就写吗？
