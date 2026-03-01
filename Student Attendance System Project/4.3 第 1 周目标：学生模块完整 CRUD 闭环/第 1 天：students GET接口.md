好。今天我们不讲概念。
我们施工。

目标只有一个：

> `GET /api/students` 能返回数据。

不分页。
不优化。
不封装统一返回。

就是打通第一条链路。

---

#  第一步：确认目录结构

你现在项目里应该有：

```
controller
service
repository
```

如果没有，建好这三层。

---

#  第二步：创建 DTO

先不要返回 entity。

新建：

```
dto/StudentDto.java
```

```java
public class StudentDto {

    private Long id;
    private String studentNo;
    private String name;
    private Long classId;
    private Integer status;

    public StudentDto(Long id, String studentNo, String name, Long classId, Integer status) {
        this.id = id;
        this.studentNo = studentNo;
        this.name = name;
        this.classId = classId;
        this.status = status;
    }

    public Long getId() { return id; }
    public String getStudentNo() { return studentNo; }
    public String getName() { return name; }
    public Long getClassId() { return classId; }
    public Integer getStatus() { return status; }
}
```

为什么不用 entity？

因为：

> API 是对外契约
> 表结构是内部实现

我们从第一天就养成这个习惯。

---

# 🧱 第三步：Repository 层

创建：

```
repository/StudentRepository.java
```

如果你用的是 `JdbcTemplate`：

```java
@Repository
public class StudentRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<StudentDto> findAll() {

        String sql = """
            SELECT id, student_no, name, class_id, status
            FROM student
            WHERE status = 1
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
}
```

注意：

* 只查 status = 1
* 不返回 created_at
* 不返回 updated_at

第一天保持干净。

---

# 🧱 第四步：Service 层

创建：

```
service/StudentService.java
```

```java
@Service
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

    public List<StudentDto> getAllStudents() {
        return studentRepository.findAll();
    }
}
```

现在 service 只是中转。

没关系。

结构先立住。

---

# 🧱 第五步：Controller 层

创建：

```
controller/StudentController.java
```

```java
@RestController
@RequestMapping("/api")
public class StudentController {

    @Autowired
    private StudentService studentService;

    @GetMapping("/students")
    public List<StudentDto> list() {
        return studentService.getAllStudents();
    }
}
```

完成。

---

# 🧪 第六步：启动服务

启动 Spring Boot。

终端测试：

```bash
curl http://localhost:8080/api/students
```

你应该看到：

```json
[
  {
    "id": 1,
    "studentNo": "2026001",
    "name": "张三",
    "classId": 1,
    "status": 1
  }
]
```

如果数据库有数据。

---

# 🔍 如果报错怎么办？

常见错误：

### ❌ 1. 找不到 Bean

检查：

* @Repository
* @Service
* @RestController
* 是否在主启动类扫描包路径下

---

### ❌ 2. SQL 报错

检查：

* 表名拼错
* 字段名 student_no 写成 studentNo

数据库字段必须用下划线。

---

# 🎯 今天的完成标准

你能：

* 用 curl 访问接口
* 返回 JSON
* 控制台没有异常

这就算 Day 1 成功。

---

# 🧠 你现在在做什么？

你正在完成：

浏览器/客户端
↓
Controller
↓
Service
↓
Repository
↓
MySQL

这是一条完整请求链。

今天打通这一条线。

后面所有接口都会复制这个节奏。

---

现在你做两件事：

1. 按步骤写代码
2. 把 curl 结果发给我

我们一起排查第一天是否彻底打通。

施工继续。 🏗
