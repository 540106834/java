
CREATE TABLE school (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,      -- 主键
    name VARCHAR(100) NOT NULL,                -- 学校名称
    code VARCHAR(32) UNIQUE,                   -- 学校编号
    address VARCHAR(255),                      -- 学校地址
    status TINYINT DEFAULT 1,                  -- 学校状态，1有效，0停用
    created_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
);