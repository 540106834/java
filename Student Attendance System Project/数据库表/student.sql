
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


--- 插入学生数据
INSERT INTO student (student_no, name, class_id) VALUES
('20250101', '陈宇轩', 1),
('20250102', '林子涵', 1),
('20250103', '张浩然', 1),
('20250104', '李雨桐', 1),
('20250105', '王俊凯', 1),
('20250106', '刘思源', 1),
('20250107', '赵梓涵', 1),
('20250108', '黄嘉怡', 1),
('20250109', '周子墨', 1),
('20250110', '吴欣妍', 1),
('20250111', '徐浩宇', 1),
('20250112', '孙雨晨', 1),
('20250113', '朱俊熙', 1),
('20250114', '胡可欣', 1),
('20250115', '郭子豪', 1),
('20250116', '何梦琪', 1),
('20250117', '高梓轩', 1),
('20250118', '梁雨泽', 1),
('20250119', '谢欣然', 1),
('20250120', '马宇航', 1);