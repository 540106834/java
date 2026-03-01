# **第 1 周目标：学生模块完整 CRUD 闭环**。


#  第 1 周目标（重新明确）

做到：

> 浏览器页面 → 调接口 → 数据入库 → 页面展示 → 删除更新成功

这是你系统的第一块真正成型的积木。

---

#  第 1 周详细执行拆解

我们拆成 5 天。

---

# ✅ 第 1 天：打通查询接口（最简单先）

目标：

```
GET /api/students
```

---

## 第一步：Repository

写查询 SQL

```java
SELECT s.id, s.student_no, s.name, s.class_id, s.status
FROM student s

mysql> SELECT s.id, s.student_no, s.name, s.class_id, s.status
    -> FROM student s
    -> ;
+----+------------+-----------+----------+--------+
| id | student_no | name      | class_id | status |
+----+------------+-----------+----------+--------+
|  1 | 20250101   | 陈宇轩    |        1 |      1 |
|  2 | 20250102   | 林子涵    |        1 |      1 |
|  3 | 20250103   | 张浩然    |        1 |      1 |
|  4 | 20250104   | 李雨桐    |        1 |      1 |
|  5 | 20250105   | 王俊凯    |        1 |      1 |
|  6 | 20250106   | 刘思源    |        1 |      1 |
|  7 | 20250107   | 赵梓涵    |        1 |      1 |
|  8 | 20250108   | 黄嘉怡    |        1 |      1 |
|  9 | 20250109   | 周子墨    |        1 |      1 |
| 10 | 20250110   | 吴欣妍    |        1 |      1 |
| 11 | 20250111   | 徐浩宇    |        1 |      1 |
| 12 | 20250112   | 孙雨晨    |        1 |      1 |
| 13 | 20250113   | 朱俊熙    |        1 |      1 |
| 14 | 20250114   | 胡可欣    |        1 |      1 |
| 15 | 20250115   | 郭子豪    |        1 |      1 |
| 16 | 20250116   | 何梦琪    |        1 |      1 |
| 17 | 20250117   | 高梓轩    |        1 |      1 |
| 18 | 20250118   | 梁雨泽    |        1 |      1 |
| 19 | 20250119   | 谢欣然    |        1 |      1 |
| 20 | 20250120   | 马宇航    |        1 |      1 |
+----+------------+-----------+----------+--------+
20 rows in set (0.00 sec)

```

如果用 jdbcTemplate：

```java
public List<StudentDto> findAll() {
    String sql = """
        SELECT id, student_no, name, class_id, status
        FROM student
    """;

    return jdbcTemplate.query(sql, (rs, rowNum) ->
        new StudentDto(
            rs.getLong("id"),
            rs.getString("student_no"),
            rs.getString("name"),
            rs.getLong("class_id"),
            rs.getInt("status")
        )
    );
}
```

---

## 第二步：Service

```java
public List<StudentDto> getAllStudents() {
    return studentRepository.findAll();
}
```

---

## 第三步：Controller

```java
@GetMapping("/api/students")
public List<StudentDto> list() {
    return studentService.getAllStudents();
}
```

---

## 第四步：用 curl 测试

```bash
curl http://localhost:8080/api/students
```

如果能返回 JSON。

第一天成功。

---

# ✅ 第 2 天：新增学生

目标：

```
POST /api/students
```

---

## 请求 JSON

```json
{
  "studentNo": "2026001",
  "name": "张三",
  "classId": 1
}
```

---

## Repository

```java
public void insert(StudentCreateRequest req) {
    String sql = """
        INSERT INTO student (student_no, name, class_id, status)
        VALUES (?, ?, ?, 1)
    """;

    jdbcTemplate.update(sql,
        req.getStudentNo(),
        req.getName(),
        req.getClassId()
    );
}
```

---

## Controller

```java
@PostMapping("/api/students")
public void create(@RequestBody StudentCreateRequest req) {
    studentService.createStudent(req);
}
```

---

## 测试

```bash
curl -X POST http://localhost:8080/api/students \
-H "Content-Type: application/json" \
-d '{"studentNo":"2026001","name":"张三","classId":1}'
```

数据库是否新增？

成功 = 第二天完成。

---

# ✅ 第 3 天：删除学生

目标：

```
DELETE /api/students/{id}
```

建议：

不要物理删除。

改成逻辑删除：

```sql
UPDATE student SET status = 0 WHERE id = ?
```

这是工程思维。

---

# ✅ 第 4 天：修改学生

目标：

```
PUT /api/students/{id}
```

SQL：

```sql
UPDATE student
SET name = ?, class_id = ?
WHERE id = ?
```

---

# ✅ 第 5 天：前端简单页面

写一个最原始 HTML 页面：

```html
<button onclick="loadStudents()">加载学生</button>
<table id="table"></table>
```

JS：

```javascript
function loadStudents() {
  fetch("/api/students")
    .then(res => res.json())
    .then(data => {
      console.log(data)
    })
}
```

让数据在浏览器出现。

---

# 🔥 第 1 周结束标准

你应该能做到：

* 浏览器打开页面
* 点按钮
* 数据加载
* 新增学生
* 修改学生
* 删除学生

这就是一个完整的系统闭环。

---

# 🧠 现在你的优势

你已经：

* 理解 HTTP
* 理解跨域
* 理解 fetch
* 理解 Controller

你现在只是把这些能力拼起来。

不是学新东西。

---

# 📌 下一步怎么做？

我们可以：

1. 今天就从 Day 1 的代码开始一起写
2. 或者你把现在 student 的代码发我，我帮你优化结构

你现在的状态不是入门阶段。

你已经是“正在造系统的人”。

我们继续推进哪一块？
