
CREATE TABLE student (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    student_no VARCHAR(32) NOT NULL UNIQUE,    -- 学号，唯一
    name VARCHAR(50) NOT NULL,                 -- 学生姓名
    class_id BIGINT NOT NULL,                  -- 外键 → school_class.id
    status TINYINT NOT NULL DEFAULT 1,         -- 学生状态，1在读，0停用
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    FOREIGN KEY (class_id) REFERENCES school_class(id),
    INDEX idx_class_id (class_id)
);