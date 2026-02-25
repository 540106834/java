
CREATE TABLE device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    device_sn VARCHAR(64) NOT NULL UNIQUE,     -- 设备序列号，唯一
    school_id BIGINT NOT NULL,                 -- 外键 → school.id
    location VARCHAR(100),                      -- 设备位置
    status TINYINT DEFAULT 1,                  -- 设备状态，1在线，0离线
    last_heartbeat DATETIME(3),
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (school_id) REFERENCES school(id),
    INDEX idx_status (status)
);

--- 插入设备数据
INSERT INTO device
(device_sn, school_id, location, status)
VALUES
('860123456789012', 1, '前门', 1);