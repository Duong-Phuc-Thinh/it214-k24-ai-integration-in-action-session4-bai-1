-- Database: medicare_appointment_db
CREATE DATABASE IF NOT EXISTS medicare_appointment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_appointment_db;

CREATE TABLE appointments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL, -- Chỉ lưu ID tham chiếu sang Patient Service, không sử dụng FK vật lý
    doctor_id BIGINT NOT NULL,  -- Chỉ lưu ID tham chiếu sang Doctor Service, không sử dụng FK vật lý
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;