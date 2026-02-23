CREATE TABLE device_raw_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '自增主键',

    device_id VARCHAR(64) NOT NULL COMMENT '设备唯一标识',

    payload TEXT NOT NULL COMMENT '设备上传原始报文内容',

    receive_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',

    parse_status TINYINT NOT NULL DEFAULT 0 COMMENT '解析状态 0=未解析 1=成功 2=失败',

    INDEX idx_device_id (device_id),
    INDEX idx_receive_time (receive_time),
    INDEX idx_parse_status (parse_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备原始日志表';