好的，我帮你把 **多学校考勤系统**的表重新梳理一下，按照 **创建顺序 + 作用说明 + 主外键和索引** 来整理，方便你落地部署。

---

## 1️ `school`（学校表）

**作用**：管理多学校信息，每个学校一条记录。

```sql
CREATE TABLE school (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    name VARCHAR(100) NOT NULL,                -- 学校名称
    code VARCHAR(32) UNIQUE,                   -- 学校编号
    address VARCHAR(255),                      -- 学校地址
    status TINYINT DEFAULT 1,                  -- 学校状态，1有效，0停用
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
);
```

* **主键**：`id`
* **唯一键**：`code`

---

## 2️ `school_class`（班级表）

**作用**：管理每个学校的班级，学生归属于班级。

```sql
CREATE TABLE school_class (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    school_id BIGINT NOT NULL,                 -- 外键 → school.id
    grade VARCHAR(20),                          -- 年级
    name VARCHAR(20),                           -- 班级名称
    status TINYINT DEFAULT 1,                  -- 班级状态
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (school_id) REFERENCES school(id)
);
```

* **主键**：`id`
* **外键**：`school_id` → `school(id)`

---

## 3️ `student`（学生表）

**作用**：存储学生基本信息，每个学生属于一个班级。

```sql
CREATE TABLE student (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    student_no VARCHAR(32) NOT NULL UNIQUE,    -- 学号，唯一
    name VARCHAR(50) NOT NULL,                 -- 学生姓名
    class_id BIGINT NOT NULL,                  -- 外键 → school_class.id
    status TINYINT NOT NULL DEFAULT 1,         -- 学生状态，1在读，0停用
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    FOREIGN KEY (class_id) REFERENCES school_class(id),
    INDEX idx_class_id (class_id)
);
```

* **主键**：`id`
* **唯一键**：`student_no`
* **外键**：`class_id` → `school_class(id)`
* **索引**：`idx_class_id`（按班级查询学生）

---

## 4️ `student_card`（学生卡表）

**作用**：记录学生绑定的考勤卡，一个学生可绑定多张卡。

```sql
CREATE TABLE student_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    student_id BIGINT NOT NULL,                -- 外键 → student.id
    card_no VARCHAR(32) NOT NULL,              -- 卡号
    status TINYINT DEFAULT 1,                  -- 卡状态，1绑定，0解绑
    bind_time DATETIME(3),
    unbind_time DATETIME(3),

    UNIQUE KEY uk_card_no (card_no),
    INDEX idx_student (student_id),
    FOREIGN KEY (student_id) REFERENCES student(id)
);
```

* **主键**：`id`
* **唯一键**：`card_no`
* **外键**：`student_id` → `student(id)`
* **索引**：`idx_student`（按学生查询卡）

---

## 5️ `device`（考勤设备表）

**作用**：记录考勤机设备信息，每台设备属于一个学校。

```sql
CREATE TABLE device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    device_sn VARCHAR(64) NOT NULL UNIQUE,     -- 设备序列号，唯一
    school_id BIGINT NOT NULL,                 -- 外键 → school.id
    location VARCHAR(100),                      -- 设备位置
    status TINYINT DEFAULT 1,                  -- 设备状态，1在线，0离线
    last_heartbeat DATETIME(3),
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (school_id) REFERENCES school(id),
    INDEX idx_status (status)
);
```

* **主键**：`id`
* **唯一键**：`device_sn`
* **外键**：`school_id` → `school(id)`
* **索引**：`idx_status`（按设备状态查询）

---

## 6️ `attendance_raw`（原始报文表）

**作用**：存储考勤机上传的原始报文，用于解析、排查问题。

```sql
CREATE TABLE attendance_raw (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    device_sn VARCHAR(64) NOT NULL,            -- 设备序列号
    sn VARCHAR(16) NOT NULL,                   -- 报文流水号
    raw_payload TEXT NOT NULL,                 -- 原始报文内容
    parsed TINYINT DEFAULT 0,                  -- 解析状态：0未解析 1成功 2失败
    error_msg VARCHAR(255) DEFAULT NULL,       -- 解析错误信息
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3)
);
```

* **主键**：`id`

---

## 7️ `attendance_record`（考勤记录表）

**作用**：解析后的考勤记录，关联学生和原始报文。

```sql
CREATE TABLE attendance_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    student_id BIGINT NOT NULL,                -- 外键 → student.id
    device_sn VARCHAR(64) NOT NULL,            -- 原始设备序列号
    check_time DATETIME(3) NOT NULL,           -- 打卡时间
    check_date DATE NOT NULL,                  -- 打卡日期
    check_type TINYINT NOT NULL,               -- 打卡类型：0上学 1放学等
    source_raw_id BIGINT NOT NULL,             -- 外键 → attendance_raw.id

    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (source_raw_id) REFERENCES attendance_raw(id)
);
```

* **主键**：`id`
* **外键**：`student_id` → `student(id)`
* **外键**：`source_raw_id` → `attendance_raw(id)`

---

##  创建顺序总结（依赖关系）

1. `school`
2. `school_class`（依赖 `school`）
3. `student`（依赖 `school_class`）
4. `student_card`（依赖 `student`）
5. `device`（依赖 `school`）
6. `attendance_raw`（不依赖其他表）
7. `attendance_record`（依赖 `student` + `attendance_raw`）

> 这样保证外键约束不会报错，先创建被引用表，再创建引用表。

---

✅ 现在这个顺序和设计可以完全支撑 **多学校 + 多班级 + 学生 + 学生卡 + 设备 + 考勤记录** 的场景，逻辑清晰且支持横向扩展。

---

如果你愿意，我可以帮你画一张 **完整 ER 图**，把每张表的关系和主外键、索引都标注出来，这样以后维护和开发都一目了然。

你希望我画吗？
