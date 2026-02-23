CREATE TABLE attendance_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',

    student_id BIGINT NOT NULL COMMENT '学生ID',
    device_sn VARCHAR(64) NOT NULL COMMENT '设备编号',

    check_time DATETIME NOT NULL COMMENT '打卡时间',
    check_date DATE NOT NULL COMMENT '打卡日期（用于统计）',

    check_type TINYINT NOT NULL COMMENT '1上课签到 2下课签退 3迟到 4早退',

    source_raw_id BIGINT COMMENT '来源原始报文ID',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_student_date (student_id, check_date),
    INDEX idx_check_time (check_time)
);