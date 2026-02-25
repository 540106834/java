
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


--- 插入学生卡数据
INSERT INTO student_card
(student_id, card_no, status, bind_time)
VALUES
(1,  '00000001', 1, NOW(3)),
(2,  '00000002', 1, NOW(3)),
(3,  '00000003', 1, NOW(3)),
(4,  '00000004', 1, NOW(3)),
(5,  '00000005', 1, NOW(3)),
(6,  '00000006', 1, NOW(3)),
(7,  '00000007', 1, NOW(3)),
(8,  '00000008', 1, NOW(3)),
(9,  '00000009', 1, NOW(3)),
(10, '00000010', 1, NOW(3)),
(11, '00000011', 1, NOW(3)),
(12, '00000012', 1, NOW(3)),
(13, '00000013', 1, NOW(3)),
(14, '00000014', 1, NOW(3)),
(15, '00000015', 1, NOW(3)),
(16, '00000016', 1, NOW(3)),
(17, '00000017', 1, NOW(3)),
(18, '00000018', 1, NOW(3)),
(19, '00000019', 1, NOW(3)),
(20, '00000020', 1, NOW(3));