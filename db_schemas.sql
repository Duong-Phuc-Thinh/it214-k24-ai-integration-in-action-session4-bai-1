-- ==================================================================
-- 1. DATABASE: medicare_patient_db
-- ==================================================================
CREATE DATABASE IF NOT EXISTS medicare_patient_db;
USE medicare_patient_db;

CREATE TABLE patients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    insurance_id VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================================================================
-- 2. DATABASE: medicare_doctor_db
-- ==================================================================
CREATE DATABASE IF NOT EXISTS medicare_doctor_db;
USE medicare_doctor_db;

CREATE TABLE doctors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    schedule TEXT, -- Lưu trữ thông tin lịch trực dưới dạng text hoặc JSON
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================================================================
-- 3. DATABASE: medicare_appointment_db
-- ==================================================================
CREATE DATABASE IF NOT EXISTS medicare_appointment_db;
USE medicare_appointment_db;

CREATE TABLE appointments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL, -- Tham chiếu sang medicare_patient_db.patients(id) bằng logic nghiệp vụ
    doctor_id BIGINT NOT NULL,  -- Tham chiếu sang medicare_doctor_db.doctors(id) bằng logic nghiệp vụ
    appointment_time DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================================================================
-- 4. DATABASE: medicare_medical_record_db
-- ==================================================================
CREATE DATABASE IF NOT EXISTS medicare_medical_record_db;
USE medicare_medical_record_db;

CREATE TABLE medical_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,     -- Tham chiếu sang medicare_patient_db.patients(id)
    doctor_id BIGINT NOT NULL,      -- Tham chiếu sang medicare_doctor_db.doctors(id)
    appointment_id BIGINT NOT NULL, -- Tham chiếu sang medicare_appointment_db.appointments(id)
    diagnosis TEXT NOT NULL,         -- Chẩn đoán
    treatment_plan TEXT,            -- Phác đồ điều trị
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE prescriptions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    medical_record_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
);

CREATE TABLE prescription_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prescription_id BIGINT NOT NULL,
    medicine_id BIGINT NOT NULL, -- Tham chiếu sang medicare_pharmacy_db.medicines(id)
    quantity INT NOT NULL CHECK (quantity > 0),
    dosage VARCHAR(100),         -- Liều dùng (ví dụ: 2 viên / ngày)
    instruction VARCHAR(255),    -- Hướng dẫn uống
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE
);

-- ==================================================================
-- 5. DATABASE: medicare_pharmacy_db
-- ==================================================================
CREATE DATABASE IF NOT EXISTS medicare_pharmacy_db;
USE medicare_pharmacy_db;

CREATE TABLE medicines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    active_ingredient VARCHAR(150), -- Hoạt chất chính
    unit VARCHAR(30) NOT NULL,       -- Đơn vị tính (Viên, Chai, Tuýp)
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);