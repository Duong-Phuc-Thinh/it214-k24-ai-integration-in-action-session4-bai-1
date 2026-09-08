import json
import time

# Giả lập dữ liệu lưu trữ vật lý trong Database của từng Service riêng biệt
# Không dùng chung database, dữ liệu chỉ liên kết thông qua ID (Reference ID)

medicare_patient_db = {
    1: {"id": 1, "full_name": "Nguyen Van A", "date_of_birth": "1990-05-15", "gender": "MALE", "phone": "0912345678", "insurance_id": "GD40101234"},
    2: {"id": 2, "full_name": "Tran Thi B", "date_of_birth": "1985-09-20", "gender": "FEMALE", "phone": "0987654321", "insurance_id": "GD40105678"}
}

medicare_doctor_db = {
    101: {"id": 101, "full_name": "Dr. Le Manh Cuong", "specialty": "Tim Mach", "phone": "0909090901", "schedule": "T2, T4, T6 Sáng"},
    102: {"id": 102, "full_name": "Dr. Nguyen Thu Trang", "specialty": "Nhi Khoa", "phone": "0909090902", "schedule": "T3, T5, T7 Chiều"}
}

medicare_appointment_db = {
    501: {"id": 501, "patient_id": 1, "doctor_id": 101, "appointment_date": "2023-11-20 09:00:00", "status": "CONFIRMED", "notes": "Khám định kỳ tim mạch"}
}

medicare_medical_record_db = {
    901: {"id": 901, "patient_id": 1, "doctor_id": 101, "appointment_id": 501, "diagnosis": "Huyết áp cao nhẹ, cần theo dõi thêm", "prescription_details": "Amlodipine 5mg", "exam_date": "2023-11-20 09:30:00"}
}

medicare_pharmacy_db = {
    "medicines": {
        1001: {"id": 1001, "code": "MED001", "name": "Amlodipine 5mg", "stock_quantity": 500, "unit_price": 1500.00},
        1002: {"id": 1002, "code": "MED002", "name": "Paracetamol 500mg", "stock_quantity": 1000, "unit_price": 500.00}
    },
    "prescriptions": {
        2001: {"id": 2001, "medical_record_id": 901, "medicine_id": 1001, "quantity": 30, "status": "PENDING"}
    }
}

# --- MICROSERVICE ENDPOINTS SIMULATION ---

class PatientService:
    @staticmethod
    def get_patient_by_id(patient_id):
        # Giả lập REST API: GET http://localhost:8081/patients/{id}
        return medicare_patient_db.get(patient_id)

class DoctorService:
    @staticmethod
    def get_doctor_by_id(doctor_id):
        # Giả lập REST API: GET http://localhost:8082/doctors/{id}
        return medicare_doctor_db.get(doctor_id)

class AppointmentService:
    @staticmethod
    def get_appointment_details(appointment_id):
        # Giả lập REST API: GET http://localhost:8083/appointments/{id}
        appointment = medicare_appointment_db.get(appointment_id)
        if not appointment:
            return None
        
        # Gọi API chéo sang các service khác để lấy thông tin liên quan
        print(f"[Appointment-Service] Đang gọi chéo Patient-Service (8081) để lấy Patient ID {appointment['patient_id']}...")
        patient_info = PatientService.get_patient_by_id(appointment["patient_id"])
        
        print(f"[Appointment-Service] Đang gọi chéo Doctor-Service (8082) để lấy Doctor ID {appointment['doctor_id']}...")
        doctor_info = DoctorService.get_doctor_by_id(appointment["doctor_id"])
        
        # Tổng hợp dữ liệu hiển thị
        result = {
            "appointment_id": appointment["id"],
            "appointment_date": appointment["appointment_date"],
            "status": appointment["status"],
            "notes": appointment["notes"],
            "patient": patient_info if patient_info else {"error": "Không tìm thấy thông tin bệnh nhân"},
            "doctor": doctor_info if doctor_info else {"error": "Không tìm thấy thông tin bác sĩ"}
        }
        return result

class MedicalRecordService:
    @staticmethod
    def add_record(patient_id, doctor_id, appointment_id, diagnosis, prescription_details):
        # Giả lập REST API: POST http://localhost:8084/medical-records
        new_id = len(medicare_medical_record_db) + 901
        record = {
            "id": new_id,
            "patient_id": patient_id,
            "doctor_id": doctor_id,
            "appointment_id": appointment_id,
            "diagnosis": diagnosis,
            "prescription_details": prescription_details,
            "exam_date": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        medicare_medical_record_db[new_id] = record
        return record

class PharmacyService:
    @staticmethod
    def dispense_medicine(prescription_id):
        # Giả lập REST API: POST http://localhost:8085/pharmacy/dispense/{id}
        pres = medicare_pharmacy_db["prescriptions"].get(prescription_id)
        if not pres:
            return {"status": "error", "message": "Không tìm thấy đơn thuốc"}
        
        med_id = pres["medicine_id"]
        quantity = pres["quantity"]
        medicine = medicare_pharmacy_db["medicines"].get(med_id)
        
        if medicine and medicine["stock_quantity"] >= quantity:
            medicine["stock_quantity"] -= quantity
            pres["status"] = "DISPENSED"
            return {
                "status": "success",
                "message": f"Đã xuất {quantity} viên {medicine['name']}",
                "remaining_stock": medicine["stock_quantity"]
            }
        else:
            return {"status": "error", "message": "Số lượng tồn kho không đủ!"}

# --- CHẠY KIỂM THỬ KỊCH BẢN NGHIỆP VỤ LIÊN HOÀN --- 
if __name__ == "__main__":
    print("=================== CHƯƠNG TRÌNH MÔ PHỎNG MICROSERVICES MEDICARE ===================\n")
    
    # Kịch bản 1: Lấy chi tiết lịch khám 501
    print("--- KỊCH BẢN 1: QUYẾT TOÁN & HIỂN THỊ THÔNG TIN LỊCH KHÁM CHÉO SERVICE ---")
    details = AppointmentService.get_appointment_details(501)
    print("\nKết quả phản hồi từ Appointment-Service:")
    print(json.dumps(details, indent=4, ensure_ascii=False))
    print("-" * 80 + "\n")
    
    # Kịch bản 2: Bác sĩ tiến hành khám, ghi nhận bệnh án mới
    print("--- KỊCH BẢN 2: GHI NHẬN HỒ SƠ BỆNH ÁN MỚI (Medical Record Service) ---")
    new_record = MedicalRecordService.add_record(
        patient_id=2, 
        doctor_id=102, 
        appointment_id=502, 
        diagnosis="Bệnh viêm họng cấp tính", 
        prescription_details="Paracetamol 500mg x 10 viên"
    )
    print("Bệnh án mới đã lưu thành công:")
    print(json.dumps(new_record, indent=4, ensure_ascii=False))
    print("-" * 80 + "\n")
    
    # Kịch bản 3: Xuất thuốc tại quầy dược
    print("--- KỊCH BẢN 3: XỬ LÝ ĐƠN THUỐC VÀ CẬP NHẬT TỒN KHO (Pharmacy Service) ---")
    print(f"Tồn kho ban đầu của thuốc {medicare_pharmacy_db['medicines'][1001]['name']}: {medicare_pharmacy_db['medicines'][1001]['stock_quantity']} viên.")
    result_dispense = PharmacyService.dispense_medicine(2001)
    print("Kết quả xuất thuốc:", result_dispense)
    print("=================================================================================")