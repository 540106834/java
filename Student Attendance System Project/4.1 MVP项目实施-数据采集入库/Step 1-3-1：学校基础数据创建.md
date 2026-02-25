
```sql
CREATE TABLE school (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(32) UNIQUE,
    address VARCHAR(255),
    status TINYINT DEFAULT 1,
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
);
```


#  第一步：插入学校数据

采用你刚刚设计的 15 位结构化编码：

```
1023303270001
```

执行：

```sql
INSERT INTO school (name, code, address, status)
VALUES (
  '苍南县五凤万向学校',
  '1023303270001',
  '浙江省温州市苍南县',
  1
);
```

---

#  第二步：确认是否插入成功

执行：

```sql
SELECT id, name, code, status FROM school;
```

你应该看到类似：

```bash
mysql> select * from school;
+----+-----------------------------+---------------+-----------------------------+--------+-------------------------+-------------------------+
| id | name                        | code          | address                     | status | created_at              | updated_at              |
+----+-----------------------------+---------------+-----------------------------+--------+-------------------------+-------------------------+
|  1 | 苍南县五凤万向学校          | 1023303270001 | 浙江省温州市苍南县          |      1 | 2026-02-25 19:38:50.560 | 2026-02-25 19:38:50.560 |
+----+-----------------------------+---------------+-----------------------------+--------+-------------------------+-------------------------+
1 row in set (0.17 sec)
```

请把查询结果贴给我，尤其是 `id`。

因为下一步建班级时，我们需要用到：

```
school_id = 这个 id
```

一步一步来，不急。
现在先确认学校是否成功入库。
