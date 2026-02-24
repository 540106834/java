CREATE TABLE attendance_raw (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '自增主键',

    device_sn VARCHAR(64) NOT NULL COMMENT '设备ID',
    sn VARCHAR(16) NOT NULL COMMENT '设备上传流水号',

    raw_payload TEXT NOT NULL COMMENT '原始报文',
    payload_hash CHAR(32) NOT NULL COMMENT 'MD5 of raw payload',

    parsed TINYINT DEFAULT 0 COMMENT '0未解析 1成功 2失败',
    error_msg VARCHAR(255) DEFAULT NULL COMMENT '解析错误信息',

    received_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',

    UNIQUE INDEX uk_payload_hash (payload_hash),
    
    INDEX idx_device_sn (device_sn),
    INDEX idx_received_at (received_at),
    INDEX idx_parsed (parsed)
);