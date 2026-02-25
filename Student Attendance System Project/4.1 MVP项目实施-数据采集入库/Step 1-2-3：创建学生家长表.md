很好，这一步开始进入“真实系统形态”了 👏

考勤系统如果没有家长联系方式，就像雷达没有天线 📡，数据再准也没人能听见。

---

# 🎯 设计目标

需求：

* 每个学生有 **2 个家长手机号**
* 至少 **1 个必须可用**
* 将来用于 **实时发送考勤短信**
* 支持修改
* 支持启停

---

# ❌ 不推荐的做法

### 方案 1：直接在 student 表加两个字段

```sql
parent_phone1
parent_phone2
```

问题：

* 扩展性差
* 以后想支持 3 个怎么办？
* 无法区分父亲母亲
* 无法记录主联系人
* 无法记录短信是否启用

像把未来锁死在今天。

---

# ✅ 推荐专业做法：独立家长表

新增一张：

## student_parent（学生家长表）

```sql
CREATE TABLE student_parent (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    student_id BIGINT NOT NULL,            -- 外键
    relation VARCHAR(20) NOT NULL,         -- 父亲/母亲/监护人
    name VARCHAR(50),                      -- 家长姓名
    phone VARCHAR(20) NOT NULL,            -- 手机号
    is_primary TINYINT DEFAULT 0,          -- 是否主联系人
    sms_enabled TINYINT DEFAULT 1,         -- 是否启用短信
    status TINYINT DEFAULT 1,              -- 1有效 0停用

    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE KEY uk_phone (phone),
    INDEX idx_student (student_id),

    FOREIGN KEY (student_id) REFERENCES student(id)
);
```

---

# 🧠 为什么这样设计更专业？

### 1️⃣ 可扩展

以后要：

* 加爷爷奶奶
* 加紧急联系人
* 加微信通知
* 加App推送

完全不用改 student 表。

---

### 2️⃣ 可以定义“必须一个可用”

业务层做校验：

```text
同一个 student_id
必须存在：
status = 1
AND sms_enabled = 1
的记录 ≥ 1
```

数据库不做复杂约束，
由业务层保证。

---

# 🧱 实际插入示例

假设 student id = 1

```sql
INSERT INTO student_parent
(student_id, relation, name, phone, is_primary, sms_enabled)
VALUES
(1, '父亲', '陈建国', '13800000001', 1, 1),
(1, '母亲', '李红梅', '13800000002', 0, 1);
```

---

# 🔥 未来短信发送逻辑会变成这样

当学生打卡：

```sql
SELECT phone
FROM student_parent
WHERE student_id = ?
AND status = 1
AND sms_enabled = 1;
```

循环发送短信即可。

---

# 🏗 你现在系统的结构就升级成：

* school
* school_class
* student
* student_card
* device
* attendance_raw
* attendance_record
* ✅ student_parent  ← 新增

这已经是一个可以商用的基础架构雏形。

---

# 🚀 下一步建议

我们可以继续推进：

1. 现在创建 student_parent 表
2. 给刚才那 10 个学生批量生成家长数据
3. 然后接入短信发送逻辑设计
4. 再优化 parser 流程

你现在这套系统，已经从“练习项目”开始变成“可上线产品”了。

要不要我带你把家长数据也批量生成一份真实感强一点的？ 📱
