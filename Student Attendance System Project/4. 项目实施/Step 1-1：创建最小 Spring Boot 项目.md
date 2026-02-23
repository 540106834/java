# **最小可上线 Spring Boot 项目初始化步骤**

#  Step 2：创建最小 Spring Boot 项目

## 1️ 用 Spring Initializr

访问 [https://start.spring.io](https://start.spring.io) 或在 IDEA 里创建。

### 配置：

* Project: Maven
* Language: Java
* Spring Boot: 3.x（最新稳定版）
* Group: `com.example`
* Artifact: `attendance`
* Packaging: Jar
* Java: 17（推荐）

### Dependencies（只选最少）：

* Spring Web → 提供 Controller/Rest API
* Spring Data JPA → 访问 MySQL 数据库
* MySQL Driver → 连接数据库

> 其他依赖暂时不选，Security / Redis / Cloud 都先不要选。

---

## 2️ 创建完成后目录结构示意

```
attendance
 ├─ src/main/java/com/example/attendance
 │    ├─ AttendanceApplication.java
 │    ├─ controller
 │    ├─ entity
 │    ├─ repository
 │    └─ service
 └─ src/main/resources
      ├─ application.yml
      └─ static / templates (可选)
```

> 建议目录保持简单，按模块拆分：
> `controller` → 接口层
> `service` → 业务逻辑
> `entity` → JPA 实体
> `repository` → 数据访问

---

## 3️ 配置数据库（application.yml）

```bash
spring.datasource.url=jdbc:mysql://192.168.11.15:3306/smart_attendance?useSSL=false&serverTimezone=Asia/Tokyo
spring.datasource.username=attend
spring.datasource.password=123456
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

> 注意：开发阶段可以用 `ddl-auto: update` 方便快速建表
> 生产环境千万不要开，改成 `validate` 或完全靠 migration 工具（Flyway / Liquibase）

---

## 4️ 创建主程序入口

```java
package com.example.attendance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AttendanceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AttendanceApplication.class, args);
    }
}
```

---

## 5️ 测试启动

* 运行 `AttendanceApplication.java`
* 控制台出现 `Tomcat started on port 8080` → 项目通电成功
* 如果报错，先检查 MySQL 数据库是否能连接


