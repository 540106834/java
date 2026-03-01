# **Day 3：删除学生接口 + 逻辑删除实现** 

目标：

> 不物理删除学生记录，而是改 `status = 0`，保证数据可追溯。
> 浏览器 / curl → Controller → Service → Repository → 数据库，完成逻辑删除。


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

    // 逻辑删除学生
    public void deleteStudent(Long id) {
        String sql = "UPDATE student SET status = 0 WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }
}
```

> ⚠️ 注意：这里没有删除数据库记录，只是把 status 改为 0。

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

    public void deleteStudent(Long id) {
        // 可加校验：如果学生不存在或已停用，提示
        studentRepository.deleteStudent(id);
    }
}
```

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

    // 逻辑删除学生接口
    @DeleteMapping("/students/{id}")
    public String deleteStudent(@PathVariable Long id) {
        studentService.deleteStudent(id);
        return "success";
    }
}
```

---

# 4️ 测试 curl

假设你要删除 id = 3 的学生：

```bash
curl -X DELETE http://192.168.11.171:8080/api/students/43
```

返回：

```text
success
```

---

# 5️ 验证数据库

```sql
SELECT id, student_no, name, status
FROM student
WHERE id = 3;
```

应该看到：

| id | student_no | name | status |
| -- | ---------- | ---- | ------ |
| 3  | 2026003    | 王五   | 0      |

✅ status 已改为 0

如果你再调用 **GET /api/students** 接口，该学生不会返回（因为我们在 Repository 查询时加了 `status = 1` 过滤）。

---

# 6️ 工程小贴士

1. **逻辑删除好处**：

* 数据可恢复
* 考勤记录不丢失
* 方便审计

2. **未来可扩展**：

* 加 `deleted_at` 时间字段
* 支持批量删除
* 后端返回删除前信息（日志审计）

---

✅ **Day 3 完成标准**：

* curl 能删除学生（逻辑删除）
* 数据库 status 改为 0
* GET /api/students 不再返回该学生

---

如果你愿意，我可以直接帮你写 **Day 4：修改学生接口（PUT /api/students/{id}）**，实现更新学生信息闭环。

你希望我直接写吗？
