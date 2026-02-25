明白了，我们把最终版本设计成 **“按班级排序，每个学生每天考勤统计，显示进校/出校（上学/放学）次数）”**，方便生成考勤报表。

假设：

* `check_type = 0` → 上学/进校
* `check_type = 1` → 放学/出校
* 学生信息在 `student` 表（`student_no`, `name`, `class_id`）
* 班级信息在 `school_class` 表（`id`, `name`）
* 考勤记录在 `attendance_record`
* 卡号在 `student_card` 表

---

### 最终 SQL 查询 + 汇总

```sql
SELECT 
    c.name AS class_name,
    s.student_no,
    s.name AS student_name,
    ar.check_date,
    COUNT(CASE WHEN ar.check_type = 0 THEN 1 END) AS in_count,
    COUNT(CASE WHEN ar.check_type = 1 THEN 1 END) AS out_count
FROM attendance_record ar
JOIN student s ON ar.student_id = s.id
JOIN student_card sc ON sc.student_id = s.id AND sc.status = 1
JOIN school_class c ON s.class_id = c.id
GROUP BY c.name, s.student_no, s.name, ar.check_date
ORDER BY c.name, s.student_no, ar.check_date;
```

---

### 🔹 功能说明

1. **JOIN 学生和班级** → 每条考勤记录对应学生和班级
2. **按日期统计进校/出校次数** →

   * `check_type = 0` → 进校次数
   * `check_type = 1` → 出校次数
3. **按班级和学号排序** → 报表按班级显示，班级内按学号排序
4. **输出列**：

   * `class_name` → 班级名称
   * `student_no` → 学号
   * `student_name` → 姓名
   * `check_date` → 打卡日期
   * `进校次数` → 上学打卡次数
   * `出校次数` → 放学打卡次数

---

### 🔹 示例输出

| class_name | student_no | student_name | check_date | 进校次数 | 出校次数 |
| ---------- | ---------- | ------------ | ---------- | ---- | ---- |
| 一年一班       | 20230001   | 张三           | 2026-02-25 | 1    | 1    |
| 一年一班       | 20230002   | 李四           | 2026-02-25 | 1    | 1    |
| 一年二班       | 20230011   | 王五           | 2026-02-25 | 1    | 1    |

---

如果你愿意，我可以帮你写 **增强版 SQL**：

* 自动把 **迟到/早退** 也显示出来
* 并统计 **总进校/出校次数** 和 **异常次数**
* 直接生成 **可用报表**

你希望我写这个增强版吗？
