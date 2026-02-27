# **查询API接口开发**

#  目标

实现两个核心查询接口：

1. `GET /api/classes`
2. `GET /api/attendance?class_id=1&date=2026-02-25`

保证：

* SQL 正确
* JSON 返回正确
* Postman / curl 能正常访问

---

#  第一步：确定返回结构（非常重要）

### `/api/classes` 返回

```json
[
  { "id": 1, "name": "01班" },
  { "id": 2, "name": "02班" }
]
```

---

### `/api/attendance` 返回

```json
[
  {
    "studentNo": "20250101",
    "studentName": "陈宇轩",
    "inCount": 1,
    "outCount": 1
  }
]
```

注意：字段命名建议用 **驼峰格式**，前端更舒服。

---

#  第二步：创建查询 Controller

建议单独建一个查询控制器：

```java
@RestController
@RequestMapping("/api")
public class AttendanceQueryController {

    @Autowired
    private AttendanceQueryService attendanceQueryService;

    @GetMapping("/classes")
    public List<ClassDto> getClasses() {
        return attendanceQueryService.getAllClasses();
    }

    @GetMapping("/attendance")
    public List<AttendanceDto> getAttendance(
            @RequestParam Long class_id,
            @RequestParam String date) {
        return attendanceQueryService.getAttendance(class_id, date);
    }
}
```

---

#  第三步：Service 层逻辑

```java
@Service
public class AttendanceQueryService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<ClassDto> getAllClasses() {
        String sql = "SELECT id, name FROM school_class";
        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new ClassDto(
                        rs.getLong("id"),
                        rs.getString("name")
                ));
    }

    public List<AttendanceDto> getAttendance(Long classId, String date) {
        String sql = """
                SELECT s.student_no,
                       s.name AS student_name,
                       COUNT(CASE WHEN ar.check_type = 0 THEN 1 END) AS in_count,
                       COUNT(CASE WHEN ar.check_type = 1 THEN 1 END) AS out_count
                FROM attendance_record ar
                JOIN student s ON ar.student_id = s.id
                JOIN student_card sc ON sc.student_id = s.id AND sc.status = 1
                WHERE s.class_id = ?
                  AND ar.check_date = ?
                GROUP BY s.student_no, s.name
                ORDER BY s.student_no
                """;

        return jdbcTemplate.query(sql, new Object[]{classId, date},
                (rs, rowNum) ->
                        new AttendanceDto(
                                rs.getString("student_no"),
                                rs.getString("student_name"),
                                rs.getInt("in_count"),
                                rs.getInt("out_count")
                        ));
    }
}
```

---

#  第四步：DTO 类

### ClassDto

```java
public record ClassDto(Long id, String name) {}
```

### AttendanceDto

```java
public record AttendanceDto(
        String studentNo,
        String studentName,
        int inCount,
        int outCount
) {}
```

使用 `record` 会让代码非常干净。

---

#  第五步：测试 API

### 测试班级接口

```
curl http://localhost:8080/api/classes
```

---

### 测试考勤接口

```
curl "http://localhost:8080/api/attendance?class_id=1&date=2026-02-25"
```

如果返回 JSON 数据，说明：

✔ SQL 正确
✔ Controller 正确
✔ 数据聚合正确
✔ MVP 查询链路打通

---

#  重要检查点

确认：

* `check_date` 类型是 DATE
* 参数 date 格式必须是 `yyyy-MM-dd`
* student_card.status = 1 是有效卡
* SQL GROUP BY 没有遗漏字段

---

#  做完这一步，你已经完成了：

```
设备 → 解析 → 入库 → 查询 API → JSON 输出
```

系统已经从“采集系统”升级为“可查询系统”。

下一步才是前端显示。

---

如果你愿意，我可以帮你再做一个：

🔹 **增强版查询 SQL**（即使当天没有打卡的学生也能显示，inCount=0）
这会让你的系统更专业。

要不要一起把这一步也升级掉？ 





