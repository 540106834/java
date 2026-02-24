
CREATE TABLE student_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    student_id BIGINT NOT NULL,                -- 外键 → student.id
    card_no VARCHAR(32) NOT NULL,              -- 卡号
    status TINYINT DEFAULT 1,                  -- 卡状态，1绑定，0解绑
    bind_time DATETIME(3),
    unbind_time DATETIME(3),

    UNIQUE KEY uk_card_no (card_no),
    INDEX idx_student (student_id),
    FOREIGN KEY (student_id) REFERENCES student(id)
);