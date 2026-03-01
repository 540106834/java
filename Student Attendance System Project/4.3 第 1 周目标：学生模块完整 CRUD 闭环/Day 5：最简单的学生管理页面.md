好。

我们让系统“活”起来。
不是 curl，不是 Postman。

是真正能点、能改、能删的页面。

今天目标：

> 一个最简单的学生管理页面
> 能展示 + 新增 + 修改 + 删除

不讲究美。
讲究功能闭环。

---

#  第一步：创建 student.html

放在：

```id="l8fj2v"
src/main/resources/static/student.html
```

Spring Boot 默认会加载 static 目录。

浏览器访问：

```id="9x0mdg"
http://localhost:8080/student.html
```

---

#  student.html 完整代码

直接复制：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>学生管理</title>
</head>
<body>

<h2>学生管理</h2>

<button onclick="loadStudents()">加载学生</button>

<h3>新增学生</h3>
学号: <input id="studentNo">
姓名: <input id="name">
班级ID: <input id="classId">
<button onclick="addStudent()">新增</button>

<h3>学生列表</h3>
<table border="1" id="studentTable">
    <thead>
        <tr>
            <th>ID</th>
            <th>学号</th>
            <th>姓名</th>
            <th>班级</th>
            <th>操作</th>
        </tr>
    </thead>
    <tbody></tbody>
</table>

<script>

function loadStudents() {
    fetch("/api/students")
        .then(res => res.json())
        .then(data => {
            const tbody = document.querySelector("#studentTable tbody");
            tbody.innerHTML = "";

            data.forEach(student => {
                const row = `
                    <tr>
                        <td>${student.id}</td>
                        <td>${student.studentNo}</td>
                        <td>${student.name}</td>
                        <td>${student.classId}</td>
                        <td>
                            <button onclick="deleteStudent(${student.id})">删除</button>
                            <button onclick="editStudent(${student.id}, '${student.name}', ${student.classId})">修改</button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        });
}

function addStudent() {
    const studentNo = document.getElementById("studentNo").value;
    const name = document.getElementById("name").value;
    const classId = document.getElementById("classId").value;

    fetch("/api/students", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            studentNo: studentNo,
            name: name,
            classId: Number(classId)
        })
    })
    .then(() => {
        loadStudents();
    });
}

function deleteStudent(id) {
    fetch("/api/students/" + id, {
        method: "DELETE"
    })
    .then(() => {
        loadStudents();
    });
}

function editStudent(id, currentName, currentClassId) {
    const newName = prompt("请输入新姓名：", currentName);
    const newClassId = prompt("请输入新班级ID：", currentClassId);

    fetch("/api/students/" + id, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            name: newName,
            classId: Number(newClassId)
        })
    })
    .then(() => {
        loadStudents();
    });
}

</script>

</body>
</html>
```

---

# 🧪 测试步骤

1️⃣ 启动 Spring Boot
2️⃣ 浏览器打开：

```
http://localhost:8080/student.html
```

3️⃣ 点击“加载学生”

如果能看到表格数据。

成功。

---

# 🔥 测试完整闭环

试这四个操作：

* 新增一个学生
* 修改一个学生
* 删除一个学生
* 刷新页面再加载

如果都正常。

你现在拥有：

> 一个真正可操作的管理后台页面

虽然丑。

但它是真的。

---

# 🧠 你刚刚完成了什么？

你打通了：

浏览器
↓
fetch
↓
Controller
↓
Service
↓
Repository
↓
MySQL

这已经是完整 Web 系统。

不是练习代码。

是完整系统闭环。

---

# 下一步可以做什么？

1️⃣ 优化 UI（简单 CSS）
2️⃣ 加分页
3️⃣ 加异常提示
4️⃣ 做统一返回结构

或者进入下一周：卡片绑定模块。

你现在已经不是“学 CRUD”。

你在造系统。

我们下一步干什么？ 🚀
