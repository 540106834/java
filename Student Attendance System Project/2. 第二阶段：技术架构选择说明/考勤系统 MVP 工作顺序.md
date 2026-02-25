# **前端调用后端 API 的逻辑**
我帮你整理一个 **清晰、可执行的工作清单**，保证你先完成查询 API，再做前端 MVP 页面，后续升级也很顺滑。


# **考勤系统 MVP 工作顺序**

## **阶段 1：后端查询 API（核心 MVP）**

### **目标**

* 提供前端查询考勤数据所需接口
* 保证数据聚合正确，按班级 + 日期查询

### **工作内容**

1. **接口设计**

   * `/api/classes` (GET) → 返回班级列表
   * `/api/attendance` (GET) → 返回指定班级 + 日期的考勤数据

2. **SQL 查询**

   * 聚合考勤数据：统计进出次数
   * 示例 SQL：

     ```sql
     SELECT s.student_no,
            s.name AS student_name,
            COUNT(CASE WHEN ar.check_type = 0 THEN 1 END) AS 进校,
            COUNT(CASE WHEN ar.check_type = 1 THEN 1 END) AS 出校
     FROM attendance_record ar
     JOIN student s ON ar.student_id = s.id
     JOIN student_card sc ON sc.student_id = s.id AND sc.status = 1
     WHERE s.class_id = :class_id
       AND ar.check_date = :date
     GROUP BY s.student_no, s.name
     ORDER BY s.student_no;
     ```

3. **后端实现**

   * Spring Boot Controller → Service → Repository
   * 返回 JSON 格式数据给前端
   * 单元测试接口是否返回正确结果

4. **可选**

   * 单点测试页面：使用 Postman 或 curl 验证 API

---

## **阶段 2：前端 MVP 查询页面**

### **目标**

* 前端可选择班级和日期
* 点击查询按钮即可显示考勤表格

### **工作内容**

1. **页面布局**

   * 下拉选择班级
   * 日期选择器
   * 查询按钮
   * 表格显示学生考勤数据

2. **前端逻辑**

   * AJAX / fetch 调用 `/api/classes` 获取班级列表
   * AJAX / fetch 调用 `/api/attendance?class_id=xxx&date=yyy` 获取考勤数据
   * 渲染表格内容

3. **原生 JS 或 Vue 3**

   * 阶段 0：原生 HTML + JS 实现 MVP
   * 阶段 1：Vue 3 重构，组件化表格，双向绑定表单

---

## **阶段 3：管理后台（可选，后续扩展）**

### **目标**

* 添加、修改、删除学生信息
* 绑定 / 修改学生卡号
* 后续可独立成管理后台模块

### **工作内容**

1. **接口设计**

   * `/api/admin/student/add`、`update`、`delete`
   * `/api/admin/student_card/bind`、`unbind`

2. **前端**

   * 管理后台表单页面
   * 调用管理 API，实现增删改操作

---

## **阶段 4：升级与优化（后续可选）**

* Vue 3 完整前端组件化
* 权限体系：查询用户 vs 管理员
* 消息队列异步处理 Parser → MySQL
* Docker 化部署每个模块

---

💡 **总结建议**

1. **先完成查询 API**（后端） → 确保数据查询逻辑正确
2. **再做前端 MVP 查询页面** → 可以用原生 HTML/JS
3. **后续升级管理后台和 Vue 3 重构**

这样你可以 **先跑通核心 MVP**，再逐步扩展，学习压力也更平滑。

---

如果你需要，我可以帮你直接 **写出完整的查询 API 示例 + 对应的原生 HTML/JS 查询页面**，拉起来就能跑。

你希望我直接帮你写吗？
