
Day 4 是一个关键点。

新增是“放进去”。
删除是“关掉”。
**修改是系统真正开始变复杂的地方。**

因为：

* 要校验
* 要判断状态
* 要避免改出脏数据
* 要考虑唯一约束

我们一步一步来。

---

#  目标

实现：

```http
PUT /api/students/{id}
```

功能：

* 修改 name
* 修改 classId
* 不允许修改 studentNo（第一版不开放）

---

#  第一步：请求 DTO

新建：

```java
public class StudentUpdateRequest {

    private String name;
    private Long classId;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Long getClassId() { return classId; }
    public void setClassId(Long classId) { this.classId = classId; }
}
```

为什么不允许改 studentNo？

因为它是业务唯一标识。
真实系统通常不允许随便改。

---

#  第二步：Repository 层

```java
public int updateStudent(Long id, String name, Long classId) {
    String sql = """
        UPDATE student
        SET name = ?, class_id = ?
        WHERE id = ? AND status = 1
    """;

    return jdbcTemplate.update(sql, name, classId, id);
}
```

注意：

```sql
AND status = 1
```

这保证：

> 停用学生不能被修改

而且返回值是影响行数。

---

# 🧠 第三步：Service 层

这里是核心。

```java
public void updateStudent(Long id, String name, Long classId) {

    StudentDto student = studentRepository.findById(id);

    if (student == null) {
        throw new RuntimeException("学生不存在");
    }

    if (student.getStatus() == 0) {
        throw new RuntimeException("学生已停用，不能修改");
    }

    if (name == null || name.isBlank()) {
        throw new RuntimeException("姓名不能为空");
    }

    if (classId == null) {
        throw new RuntimeException("班级不能为空");
    }

    int rows = studentRepository.updateStudent(id, name, classId);

    if (rows == 0) {
        throw new RuntimeException("更新失败");
    }
}
```

你现在看到一个重要逻辑：

* 查
* 判断
* 再更新
* 再确认

这是标准业务流程。

---

# 🧩 第四步：Controller 层

```java
@PutMapping("/students/{id}")
public Map<String, Object> updateStudent(
        @PathVariable Long id,
        @RequestBody StudentUpdateRequest req) {

    studentService.updateStudent(id, req.getName(), req.getClassId());

    return Map.of(
            "code", 0,
            "message", "success"
    );
}
```

---

# 🧪 测试 curl

```bash
curl -X PUT http://localhost:8080/api/students/1 \
-H "Content-Type: application/json" \
-d '{
    "name": "陈宇轩-修改",
    "classId": 2
}'
```

返回：

```json
{
  "code": 0,
  "message": "success"
}
```

数据库验证：

```sql
SELECT id, name, class_id FROM student WHERE id = 1;
```

应该看到更新后的值。

---

# ❌ 异常测试

### 修改不存在学生

```bash
curl -X PUT http://localhost:8080/api/students/999 \
-H "Content-Type: application/json" \
-d '{"name":"测试","classId":1}'
```

返回错误。

---

### 修改已停用学生

会提示：

```text
学生已停用，不能修改
```

---

# 🧠 现在你完成了什么？

你已经具备：

✔ 新增
✔ 查询
✔ 删除（逻辑）
✔ 修改

这四个组合起来叫：

> 一个完整资源管理模块

你现在的学生模块，已经是一个完整的后台模块。

不是练习，是模块。

---

# 🔥 下一步建议

Day 5 我建议做：

👉 简单前端页面，把这 4 个接口全部接上
或者
👉 做统一异常处理，让接口更专业

你想把系统“能看”，还是“更专业”？
