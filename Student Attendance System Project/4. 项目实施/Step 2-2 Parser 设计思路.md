很好，现在我们进入整个系统里**最有灵魂的一层**：

> 🌪 Parser 层
> 把“设备语言”翻译成“数据库语言”

你现在其实已经有两张表：

* `attendance_raw` → 原始报文仓库（不相信设备，先原样存档）
* `attendance_record` → 结构化后的业务数据（可统计、可查询）

Parser 就是那条**炼金术流水线**：
原始字符串 → 校验 → 拆字段 → 业务对象 → 写入 record → 更新 raw 状态

---

# 一、Parser 在三层架构中的位置

结构应该是：

```
Controller
    ↓
RawService.saveRaw()
    ↓
ParserService.parse(rawId)
        ↓
        1. 校验报文合法性
        2. 拆解字段
        3. 生成 AttendanceRecord
        4. 更新 raw.parsed 状态
```

Parser 绝对不要写在 Controller 里。
Controller 只负责“收件”，Parser 负责“破译”。

---

# 二、建议的 Parser 分层设计

### 1️⃣ 报文对象模型（中间态）

```java
public class DeviceMessage {

    private String deviceSn;
    private String sn;
    private String cardNo;
    private LocalDateTime checkTime;
    private Integer checkType;

}
```

这是“设备语”翻译后的中间语言。

---

### 2️⃣ ParserService 接口

```java
public interface ParserService {

    void parseAndPersist(Long rawId);

}
```

---

### 3️⃣ 实现逻辑（核心设计思路）

逻辑流程：

```
1. 根据 rawId 查询 attendance_raw
2. 校验长度
3. 校验 checksum
4. 拆字段
5. 转成 DeviceMessage
6. 转成 AttendanceRecord
7. 保存 record
8. 更新 raw.parsed
```

---

# 三、字段拆解逻辑设计

你给的报文：

```
DIRM01003209000186012345678901212345678202602231530450 0A
```

我们按固定位置截取：

| 字段        | 截取区间  |
| --------- | ----- |
| device_sn | 16~31 |
| sn        | 14~16 |
| body      | 31~53 |

可以设计为：

```java
String deviceSn = payload.substring(16, 31);
String sn = payload.substring(14, 16);
String body = payload.substring(31, 53);
```

然后 body 再拆：

```java
String cardNo = body.substring(0, 8);
String timeStr = body.substring(8, 22);
String typeStr = body.substring(22, 23);
```

---

# 四、校验逻辑（非常关键）

## 1️⃣ 长度校验

报文中有：

```
0032
```

说明整个报文长度应该为 32 字节。

可以做：

```java
int declaredLength = Integer.parseInt(payload.substring(6, 10));
if (payload.length() != declaredLength) {
    throw new RuntimeException("报文长度不一致");
}
```

---

## 2️⃣ 校验和（最后 2 位）

你现在尾部是 `0A`
可以先不做复杂算法，只做基础：

```java
String checksum = payload.substring(payload.length() - 2);
```

未来再扩展为 CRC 或 XOR。

---

# 五、状态机设计（raw.parsed）

| 状态 | 含义  |
| -- | --- |
| 0  | 未解析 |
| 1  | 成功  |
| 2  | 失败  |

Parser 应该：

* 成功 → 写 record → raw.parsed=1
* 失败 → raw.parsed=2 + error_msg

这样 raw 表就成了**可追溯的日志仓库**

---

# 六、推荐的最终结构图

```
attendance_raw
      ↓
   Parser
      ↓
DeviceMessage
      ↓
attendance_record
```

你可以把 raw 想成：

> 📦 冷冻仓库

Parser：

> 🔬 实验室

Record：

> 📊 业务数据库

---

# 七、一个更专业的升级建议

你现在用：

```sql
UNIQUE INDEX uk_payload_hash (payload_hash)
```

非常好 👍

但 Parser 还应该增加：

```sql
source_raw_id
```

在 record 表中保留来源。

这叫：

> 🔗 可追溯架构

当统计错误、对账异常时，你能直接回溯到原始报文。

---

# 八、未来升级路线（企业级进阶）

当并发变大时：

```
HTTP 接收
    ↓
写 raw
    ↓
Kafka
    ↓
Parser Consumer
    ↓
写 record
```

Parser 会变成异步消费服务。

你现在这个设计，其实已经是：

> 🧱 企业级架构雏形

而不是玩具系统。

---

如果你愿意，我可以给你：

* 一份完整的 ParserService 实现代码
* 或者画一张《考勤报文解析流程图》
* 或者带你做成异步版本

你现在已经进入真正的后端工程设计阶段了。
这不是“写代码”，这是在建一条数据生产线。
