好，这一步我们做一件非常“数据平台味”的事情 🍵

不再查“某一天谁来了”，
而是开始回答一个更有力量的问题：

> 这个班最近表现如何？

我们把它设计成一个**可接入监控系统的统计接口**。

---

# 🎯 目标

支持：

* ✅ 按周统计
* ✅ 按月统计
* ✅ 自定义时间区间
* ✅ 返回可直接用于监控图表的数据结构

---

# 一、接口设计（统一成一个）

建议不要拆三个接口，而是做成一个“区间统计接口”：

```
GET /api/classes/{classId}/attendance/daily-stats?start=2026-02-01&end=2026-02-28
```

优点：

* 周 = 7天区间
* 月 = 30天区间
* Grafana 直接传时间范围
* 逻辑统一，代码干净

---

# 二、返回结构设计（适合画图）

```json
[
  {
    "date": "2026-02-01",
    "inTotal": 43,
    "outTotal": 42
  },
  {
    "date": "2026-02-02",
    "inTotal": 45,
    "outTotal": 45
  }
]
```

特点：

✔ 每天一条
✔ 适合折线图
✔ Prometheus / Grafana 也能吃

---

# 三、SQL 设计（核心）

关键点：

* 必须按天 GROUP BY
* 必须统计 进校 / 出校
* 必须排序

```sql
SELECT 
    ar.check_date,
    COUNT(CASE WHEN ar.check_type = 0 THEN 1 END) AS in_total,
    COUNT(CASE WHEN ar.check_type = 1 THEN 1 END) AS out_total
FROM attendance_record ar
JOIN student s ON ar.student_id = s.id
WHERE s.class_id = ?
  AND ar.check_date BETWEEN ? AND ?
GROUP BY ar.check_date
ORDER BY ar.check_date
```

这是一条非常“监控友好”的 SQL。

---

# 四、Controller

```java
@GetMapping("/attendance/stats")
public List<AttendanceStatsDto> getStats(
        @RequestParam Long class_id,
        @RequestParam String start,
        @RequestParam String end) {

    return attendanceQueryService.getStats(class_id, start, end);
}
```

---

# 五、Service

```java
public List<AttendanceStatsDto> getStats(
        Long classId, String start, String end) {

    String sql = """
        SELECT 
            ar.check_date,
            COUNT(CASE WHEN ar.check_type = 0 THEN 1 END) AS in_total,
            COUNT(CASE WHEN ar.check_type = 1 THEN 1 END) AS out_total
        FROM attendance_record ar
        JOIN student s ON ar.student_id = s.id
        WHERE s.class_id = ?
          AND ar.check_date BETWEEN ? AND ?
        GROUP BY ar.check_date
        ORDER BY ar.check_date
    """;

    return jdbcTemplate.query(sql,
        (rs, rowNum) -> new AttendanceStatsDto(
                rs.getDate("check_date").toLocalDate(),
                rs.getInt("in_total"),
                rs.getInt("out_total")),
        classId, start, end);
}
```

---

# 六、DTO

```java
import java.time.LocalDate;

public record AttendanceStatsDto(
        LocalDate date,
        int inTotal,
        int outTotal
) {}
```

---

# 七、测试

```
curl "http://localhost:8080/api/attendance/stats?class_id=1&start=2026-02-01&end=2026-02-28"
```

如果返回 JSON 数组：

✔ 区间统计成功
✔ 可接入前端图表
✔ 可对接 Grafana

---

# 八、为“监控系统”再升级一点（很关键）

现在有一个隐藏问题：

⚠ 如果某一天没有任何打卡记录，这一天会消失。

监控图会断线。

---

# 升级方案（推荐）

用日期表或生成连续日期。

MySQL 8 可以用递归 CTE：

```sql
WITH RECURSIVE dates AS (
    SELECT ? AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM dates
    WHERE dt < ?
)
SELECT 
    d.dt,
    COALESCE(SUM(CASE WHEN ar.check_type = 0 THEN 1 END),0) AS in_total,
    COALESCE(SUM(CASE WHEN ar.check_type = 1 THEN 1 END),0) AS out_total
FROM dates d
LEFT JOIN attendance_record ar
    ON ar.check_date = d.dt
LEFT JOIN student s
    ON ar.student_id = s.id AND s.class_id = ?
GROUP BY d.dt
ORDER BY d.dt;
```

这就变成：

🧠 监控级 SQL
📈 图永远连续
🔍 0 值可见

---

# 九、架构意义

你现在系统已经开始具备：

* 数据采集
* 统计聚合
* 区间查询
* 时间序列能力

再往前一步，就是：

```
Prometheus Exporter
```

那时候你的系统会变成：

> 一个可以被观测的业务系统

而不是一个“简单的接口”。

---

# 明天可以做什么？

我建议明天做：

👉 统计出勤率（百分比）
👉 或者加“按周自动分组统计”

你想走哪条进化路线？

1️⃣ 出勤率
2️⃣ 周自动分组
3️⃣ 监控指标输出格式优化

选一个，我们继续往“专业系统”进化。 🚀
