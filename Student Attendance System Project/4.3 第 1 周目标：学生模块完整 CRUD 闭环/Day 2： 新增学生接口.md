好的，我们直接动手做 **Day 2：新增学生接口（POST /api/students）** 

目标：

> 浏览器 / curl → Controller → Service → Repository → 数据库
> 成功新增学生记录

---

# 1️ Repository 层

```java
package repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class StudentRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 新增学生
    public void insertStudent(String studentNo, String name, Long classId) {
        String sql = """
            INSERT INTO student (student_no, name, class_id, status)
            VALUES (?, ?, ?, 1)
        """;
        jdbcTemplate.update(sql, studentNo, name, classId);
    }
}
```

---

# 2️ Service 层

```java
package service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import repository.StudentRepository;

@Service
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

    public void createStudent(String studentNo, String name, Long classId) {
        // 这里可以增加校验，比如 studentNo 不重复
        studentRepository.insertStudent(studentNo, name, classId);
    }
}
```

> ⚠️ 工程思维：studentNo 唯一性由数据库约束保证，Service 可加提示，但不要依赖前端。

---

# 3️ Controller 层

```java
package controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import service.StudentService;

@RestController
@RequestMapping("/api")
public class StudentController {

    @Autowired
    private StudentService studentService;

    // 新增学生接口
    @PostMapping("/students")
    public String createStudent(@RequestBody StudentCreateRequest req) {
        studentService.createStudent(req.getStudentNo(), req.getName(), req.getClassId());
        return "success";
    }
}

// 请求 DTO
class StudentCreateRequest {
    private String studentNo;
    private String name;
    private Long classId;

    // getter & setter
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Long getClassId() { return classId; }
    public void setClassId(Long classId) { this.classId = classId; }
}
```

---

# 4️ 测试 curl

```bash
curl -X POST http://192.168.11.171:8080/api/students \
-H "Content-Type: application/json" \
-d '{
    "studentNo": "20250121",
    "name": "金嘉怡",
    "classId": 1
}'
```

返回：

```text
success
```

---

# 5️ 验证数据库

```sql
SELECT * FROM student WHERE student_no='20250121';
```

应该能看到新记录：
```bash
mysql> select * from student where student_no=20250121;
+----+------------+-----------+----------+--------+-------------------------+-------------------------+
| id | student_no | name      | class_id | status | created_at              | updated_at              |
+----+------------+-----------+----------+--------+-------------------------+-------------------------+
| 43 | 20250121   | 金嘉怡    |        1 |      1 | 2026-03-01 22:28:48.811 | 2026-03-01 22:28:48.811 |
+----+------------+-----------+----------+--------+-------------------------+-------------------------+
```

---

# 6️ 工程小贴士

1. **唯一约束**
   数据库已经 `student_no UNIQUE`，Service 可捕获异常返回友好信息。

2. **参数校验**
   可以先检查：

```java
if(studentNo==null || name==null || classId==null) throw new RuntimeException("参数不完整");
```

3. **返回格式**
   以后可以统一成 JSON：

```json
{ "code":0, "message":"success" }
```

今天这样打通接口即可。

---

✅ **Day 2 完成标准**：

* curl 能新增学生
* 数据库能看到新增记录
* status = 1 自动生效

---

如果你愿意，我可以帮你 **写 Day 3：删除学生接口 + 逻辑删除实现**，直接接着 Day 2。

你希望我直接写吗？
