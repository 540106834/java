
CREATE TABLE school_class (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    school_id BIGINT NOT NULL,                 -- 外键 → school.id
    grade VARCHAR(20),                          -- 年级
    name VARCHAR(20),                           -- 班级名称
    status TINYINT DEFAULT 1,                  -- 班级状态
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (school_id) REFERENCES school(id)
);


--- 插入班级数据
INSERT INTO school_class (school_id, grade, name, status)
VALUES (1, '2025级', '01班', 1);

--- 查询班级数据
mysql> select * from school_class;
+----+-----------+---------+-------+--------+-------------------------+
| id | school_id | grade   | name  | status | created_at              |
+----+-----------+---------+-------+--------+-------------------------+
|  1 |         1 | 2025级  | 01班  |      1 | 2026-02-25 19:54:05.584 |
+----+-----------+---------+-------+--------+-------------------------+

UPDATE school_class
SET grade = '2025级',
    name = '01班'
WHERE id = 1;