明白了，我给你整理一个 **多学校考勤系统完整 ER 图**，把你现在的表和依赖关系都展示出来，同时标注主键、外键和索引关系。这里用文本+关系箭头表示，清晰可视化整个结构。

---

##  完整 ER 图（多学校 + 班级 + 学生 + 学生卡 + 设备 + 考勤）

```text
+------------------+
|      school      |
+------------------+
| PK id            |
| name             |
| code (UNIQUE)    |
| address          |
| status           |
| created_at       |
| updated_at       |
+------------------+
        |
        | 1
        |  
        v *
+------------------+
|   school_class   |
+------------------+
| PK id            |
| school_id FK -> school(id)  |
| grade            |
| name             |
| status           |
| created_at       |
+------------------+
        |
        | 1
        |  
        v *
+------------------+
|     student      |
+------------------+
| PK id            |
| student_no UNIQUE|
| name             |
| class_id FK -> school_class(id) |
| status           |
| created_at       |
| updated_at       |
+------------------+
        |
        | 1
        |  
        v *
+------------------+
|   student_card   |
+------------------+
| PK id            |
| student_id FK -> student(id) |
| card_no UNIQUE   |
| status           |
| bind_time        |
| unbind_time      |
+------------------+

+------------------+
|      device      |
+------------------+
| PK id            |
| device_sn UNIQUE |
| school_id FK -> school(id) |
| location         |
| status           |
| last_heartbeat   |
| created_at       |
+------------------+
        |
        | 1
        |
        v *
+------------------+
|  attendance_raw  |
+------------------+
| PK id            |
| device_sn        |
| sn               |
| raw_payload      |
| parsed           |
| error_msg        |
| created_at       |
+------------------+
        |
        | 1
        |
        v *
+----------------------+
|  attendance_record   |
+----------------------+
| PK id                |
| student_id FK -> student(id) |
| device_sn            |
| check_time           |
| check_date           |
| check_type           |
| source_raw_id FK -> attendance_raw(id) |
+----------------------+
```

---

### 🔹 ER 图说明

1. **学校维度**：`school` 是顶层，每个学校有多个班级和设备
2. **班级维度**：`school_class` 关联学校，学生属于班级
3. **学生维度**：`student` 通过班级归属学校
4. **学生卡**：`student_card` 一对多，支持多个卡号
5. **设备维度**：`device` 属于学校，上传考勤原始报文
6. **考勤原始报文**：`attendance_raw` 记录每次设备上报的原始数据
7. **考勤记录**：`attendance_record` 解析后的考勤，关联学生和原始报文

---

###  主外键 & 索引总结

| 表名                | 主键 | 外键                                                           | 唯一键        | 索引                      |
| ----------------- | -- | ------------------------------------------------------------ | ---------- | ----------------------- |
| school            | id | -                                                            | code       | -                       |
| school_class      | id | school_id → school(id)                                       | -          | -                       |
| student           | id | class_id → school_class(id)                                  | student_no | idx_class_id(class_id)  |
| student_card      | id | student_id → student(id)                                     | card_no    | idx_student(student_id) |
| device            | id | school_id → school(id)                                       | device_sn  | idx_status(status)      |
| attendance_raw    | id | -                                                            | -          | -                       |
| attendance_record | id | student_id → student(id), source_raw_id → attendance_raw(id) | -          | -                       |

---

这个 ER 图可以直接用来做：

* 数据库建表顺序
* 数据库文档说明
* 系统横向扩展（多学校、多班级、多学生、多设备）

---

如果你愿意，我可以帮你画一个 **图形化的 ER 图 PNG 或 SVG**，标明所有主外键和索引，像企业级数据库设计图一样，非常直观。

你希望我帮你画吗？
