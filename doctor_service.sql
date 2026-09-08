-- Database: medicare_doctor_db
CREATE DATABASE IF NOT EXISTS medicare_doctor_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_doctor_db;

CREATE TABLE doctors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    schedule TEXT, -- Ví dụ: "Thứ 2, 4, 6 Sáng"
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;