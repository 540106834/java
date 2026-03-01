好。今天继续施工，不开会。

你这个判断是对的。

> 查全部是展示。
> 查单个是校验的地基。

以后做：

* 更新前要查
* 删除前要查
* 逻辑删除要判断是否存在
* 业务校验要判断状态

所以我们现在就把“查单个”这条链路补上。

不复杂，但非常关键。

---

# 🎯 目标

新增：

```
GET /api/students/{id}
```

返回单个学生。

---

# 🧱 第一步：Repository 增加方法

在 `StudentRepository` 里加：

```java
public StudentDto findById(Long id) {

    String sql = """
        SELECT id, student_no, name, class_id, status
        FROM student
        WHERE id = ? AND status = 1
    """;

    List<StudentDto> list = jdbcTemplate.query(sql,
            new Object[]{id},
            (rs, rowNum) -> new StudentDto(
                    rs.getLong("id"),
                    rs.getString("student_no"),
                    rs.getString("name"),
                    rs.getLong("class_id"),
                    rs.getInt("status")
            )
    );

    return list.isEmpty() ? null : list.get(0);
}
```

为什么不直接用 `queryForObject`？

因为：

* 查不到会抛异常
* 你后面还要做业务判断

我们自己控制返回 null，逻辑更清晰。

---

# 🧱 第二步：Service 增加方法

```java
public StudentDto getStudentById(Long id) {
    return studentRepository.findById(id);
}
```

现在还是中转。

后面这里会长肉。

---

# 🧱 第三步：Controller 增加接口

```java
@GetMapping("/students/{id}")
public StudentDto getById(@PathVariable Long id) {
    return studentService.getStudentById(id);
}
```

完成。

---

# 🧪 测试

```bash
curl http://localhost:8080/api/students/1
```

返回：

```json
{
  "id": 1,
  "studentNo": "2026001",
  "name": "张三",
  "classId": 1,
  "status": 1
}
```

如果不存在：

```
null
```

现在先允许 null。

下一步我们再升级成：

* 不存在 → 404
* 已停用 → 提示
* 参数非法 → 400

---

# 🧠 你现在的结构已经具备

* 查全部
* 查单个
* 可支持更新前校验
* 可支持删除前校验

这就像搭好了一条主干光纤，后面所有业务都是插设备。

---

# ⚙️ 小优化建议（可选）

如果你想写得更优雅一点，可以把 RowMapper 抽出来：

```java
private RowMapper<StudentDto> rowMapper = (rs, rowNum) ->
        new StudentDto(
                rs.getLong("id"),
                rs.getString("student_no"),
                rs.getString("name"),
                rs.getLong("class_id"),
                rs.getInt("status")
        );
```

然后：

```java
jdbcTemplate.query(sql, rowMapper);
```

避免重复。

---

下一步你想干什么？

* 把查单个升级成 404？
* 开始做 PUT 更新？
* 还是先做逻辑删除校验？

今天我们继续铺管道。🚧
