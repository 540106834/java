CREATE DATABASE IF NOT EXISTS smart_attendance 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;
use smart_attendane;

CREATE USER 'attend'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON smart_attendance.* TO 'attend'@'%';
SHOW GRANTS FOR 'attend'@'%';

FLUSH PRIVILEGES;