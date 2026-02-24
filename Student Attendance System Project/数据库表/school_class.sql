
CREATE TABLE school_class (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    school_id BIGINT NOT NULL,                 -- 外键 → school.id
    grade VARCHAR(20),                          -- 年级
    name VARCHAR(20),                           -- 班级名称
    status TINYINT DEFAULT 1,                  -- 班级状态
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (school_id) REFERENCES school(id)
);