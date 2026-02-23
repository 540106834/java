# **Parser 层（解析层）**
这是 Raw 表到结构化表的核心桥梁，也是企业级架构中**数据流与业务解耦的关键**。

我会结合你现有的 `attendance_raw` 表和解析后的 `attendance_record` 表，给你一个完整设计方案。


#  Parser 层定位

**职责**：

1. 从 Raw 表读取未解析或解析失败的报文
2. 校验报文完整性（包长度、校验和）
3. 解析 ASCII 定长报文 → 业务字段
4. 写入结构化考勤表 (`attendance_record`)
5. 更新 Raw 表解析状态和错误信息

>  重点：Parser 层只处理解析逻辑，不做业务决策。业务逻辑放在 Attendance Service 层。

---

#  Parser 层组件设计

```text id="parser_layer_design"
┌───────────────────────┐
│   Parser Service       │
│───────────────────────│
│ - fetchRawLogs()       │ <- 从 attendance_raw 查询未解析报文
│ - validateChecksum()   │ <- 校验报文长度 + 校验和
│ - parsePayload()       │ <- 拆解报文 ASCII 字段
│ - mapToAttendance()    │ <- 转换成 AttendanceRecord 对象
│ - saveAttendance()     │ <- 插入 attendance_record
│ - updateRawStatus()    │ <- 更新 parsed / error_msg
└───────────────────────┘
```

---

#  解析流程示意

```text id="parser_flow"
Raw 表（attendance_raw）
        │
        ▼
1. fetchRawLogs()      --> SELECT * FROM attendance_raw WHERE parsed = 0
        │
        ▼
2. validateChecksum()  --> 包长度/校验和校验失败？标记 parsed=2, error_msg
        │
        ▼
3. parsePayload()      --> 拆解 ASCII 定长字段：
                            device_type / function_code / sequence_no
                            device_sn / card_no / event_time / event_type
        │
        ▼
4. mapToAttendance()   --> 构造 AttendanceRecord 对象
        │
        ▼
5. saveAttendance()    --> INSERT INTO attendance_record
        │
        ▼
6. updateRawStatus()   --> parsed = 1 成功 / 2 失败
```

---

#  核心设计要点

1. **幂等保障**

   * 使用 Raw 表唯一约束 (`payloadHash`)
   * 插入 Attendance 表前检查同样的 payloadHash 是否存在

2. **批量处理**

   * 一次性处理 N 条报文，提升性能
   * 每条报文异常独立处理，不影响其他报文

3. **异常处理**

   * parse 错误写入 `error_msg`
   * 可重试解析失败报文
   * 便于运维排查

4. **可扩展性**

   * 新功能号 F10/F11 只需要增加解析逻辑，不影响数据库结构
   * Parser 层与 TCP 服务、业务层解耦

5. **事务管理**

   * 原则：Raw 表更新状态与 Attendance 表插入可以**单条事务**
   * 批量处理时每条报文独立事务，避免一条报错导致全部回滚

---

#  技术实现建议（Spring Boot）

* **Service 类**：`AttendanceParserService`
* **定时任务/调度**：每 N 秒抓取未解析报文
* **工具类**：`AsciiPayloadParser` 负责定长 ASCII 拆解
* **日志**：记录每条报文解析结果、异常原因

```java
@Component
public class AttendanceParserService {

    @Autowired
    private AttendanceRawRepository rawRepo;
    
    @Autowired
    private AttendanceRecordRepository attendanceRepo;

    @Transactional
    public void parseRawBatch() {
        List<AttendanceRaw> raws = rawRepo.findUnparsedBatch(100);
        for (AttendanceRaw raw : raws) {
            try {
                if (!validateChecksum(raw)) {
                    raw.setParsed((byte)2);
                    raw.setErrorMsg("Checksum error");
                    rawRepo.save(raw);
                    continue;
                }
                AttendanceRecord record = parsePayload(raw);
                attendanceRepo.save(record);
                raw.setParsed((byte)1);
                rawRepo.save(raw);
            } catch (Exception e) {
                raw.setParsed((byte)2);
                raw.setErrorMsg(e.getMessage());
                rawRepo.save(raw);
            }
        }
    }
}
```

> ⚠ 注意：每条报文独立 try/catch，保证批量解析不中断

---

# 🔹 Parser 层优势

1. **单一职责**：只解析，不做业务
2. **易扩展**：新设备、新功能号增加解析逻辑即可
3. **易维护**：解析错误可追踪到 Raw 表
4. **运维友好**：可定时任务处理、可重跑、可监控

---

如果你愿意，我可以帮你画一个 **Raw 表 → Parser → Attendance 表 → 家长查询 API 的完整数据流图**，把整个单体阶段的架构一目了然，适合运维架构师思维训练。

你希望我画吗？
