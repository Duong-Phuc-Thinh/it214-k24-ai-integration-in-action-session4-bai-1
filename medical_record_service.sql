-- Database: medicare_medical_record_db
CREATE DATABASE IF NOT EXISTS medicare_medical_record_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_medical_record_db;

CREATE TABLE medical_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,     -- Lưu ID tham chiếu
    doctor_id BIGINT NOT NULL,      -- Lưu ID tham chiếu
    appointment_id BIGINT NOT NULL, -- Lưu ID tham chiếu
    diagnosis TEXT NOT NULL,
    prescription_details TEXT,
    exam_date DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;