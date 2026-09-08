# Hệ Thống Quản Lý Bệnh Viện MediCare - Kiến trúc Microservices

## 1. Phân Tích và Chia Module Microservices
Hệ thống Monolith của Bệnh viện MediCare được tách thành 5 Microservices riêng biệt, hoạt động độc lập và sử dụng cơ sở dữ liệu riêng (Database-per-Service):

| Tên Microservice | Cổng (Port) | Cơ sở dữ liệu tương ứng | Mô tả lý do phân tách |
|---|---|---|---|
| **Patient Service** | `8081` | `medicare_patient_db` | Quản lý thông tin hồ sơ cá nhân và BHYT của bệnh nhân. Service này hoạt động độc lập để tối ưu việc đăng ký thông tin mới, tra cứu thông tin mà không ảnh hưởng tới các nghiệp vụ lâm sàng khác. |
| **Doctor Service** | `8082` | `medicare_doctor_db` | Quản lý thông tin lý lịch bác sĩ, chuyên khoa và lịch trình trực/khám. Việc tách riêng giúp phòng quản lý nhân sự cập nhật thông tin và ca trực mà không can thiệp vào tiến trình đặt lịch hay khám bệnh. |
| **Appointment Service** | `8083` | `medicare_appointment_db` | Quản lý việc đăng ký, hủy lịch, và điều phối ca khám. Đây là service có tần suất chịu tải cao trong khung giờ cao điểm, cần hạ tầng chịu tải tốt và cơ chế xử lý đồng thời để tránh trùng lặp lịch khám. |
| **Medical Record Service** | `8084` | `medicare_medical_record_db` | Quản lý kết quả chẩn đoán, lịch sử bệnh án và đơn thuốc. Thông tin bệnh án là dữ liệu cực kỳ nhạy cảm, cần bảo mật cao (tuân thủ tiêu chuẩn như HIPAA), phân tách độc lập để dễ dàng áp dụng mã hóa dữ liệu. |
| **Pharmacy Service** | `8085` | `medicare_pharmacy_db` | Quản lý kho thuốc và xuất thuốc theo đơn. Tách biệt kho dược giúp bộ phận dược sĩ quản lý xuất nhập tồn kho độc lập, không làm ảnh hưởng đến hoạt động khám và chẩn đoán của bác sĩ. |

### Sơ đồ kiến trúc kết nối và Giải pháp liên kết dữ liệu
Vì áp dụng nguyên tắc **Database-per-Service**, không một service nào được quyền truy cập trực tiếp vào database của service khác. Các bảng liên kết chéo (ví dụ: Lịch khám cần thông tin Bác sĩ và Bệnh nhân) sẽ không dùng khóa ngoại vật lý và câu lệnh SQL `JOIN` xuyên cơ sở dữ liệu.

**Giải pháp:**
- Lưu ID tham chiếu: Bảng `appointments` ở Appointment Service chỉ lưu `patient_id` và `doctor_id` dưới dạng số nguyên (`BIGINT`).
- Khi cần hiển thị thông tin đầy đủ, Appointment Service sẽ gửi truy vấn HTTP REST API (hoặc gRPC) tới Patient Service và Doctor Service để lấy thông tin chi tiết qua ID.

```
                    +--------------------+ 
                    |    API GATEWAY     |
                    +---------+----------+
                              |
      +--------------+--------+-------+---------------+-----------------+
      |              |                |               |                 |
+-----v-----+  +-----v-----+    +-----v-----+   +-----v-----+     +-----v-----+
| Patient   |  |  Doctor   |    |Appointment|   | Medical   |     | Pharmacy  |
| Service   |  |  Service  |    |  Service  |   |  Record   |     |  Service  |
| (Port8081)|  | (Port8082)|    | (Port8083)|   | (Port8084)|     | (Port8085)|
+-----++----+  +-----++----+    +-----++----+   +-----++----+     +-----++----+
      ||             ||               ||              ||                ||
+-----vv----+  +-----vv----+    +-----vv----+   +-----vv----+     +-----vv----+
|  MySQL    |  |  MySQL    |    |  MySQL    |   |  MySQL    |     |  MySQL    |
|  patient  |  |  doctor   |    |appointment|   |  medical  |     |  pharmacy |
|    _db    |  |    _db    |    |    _db    |   | record_db |     |    _db    |
+-----------+  +-----------+    +-----------+   +-----------+     +-----------+
```

---

## 2. Cách Chạy Chương Trình Mô Phỏng
Để minh họa sinh động cách thức hoạt động của 5 Microservice cùng cách xử lý truy cập dữ liệu chéo không dùng SQL JOIN, một chương trình giả lập bằng Python đã được xây dựng hoàn chỉnh.

### Chạy trực tiếp qua Python:
```bash
python app.py
```
Khi chạy, ứng dụng sẽ thực hiện khởi tạo cơ sở dữ liệu mô phỏng, sau đó chạy kịch bản:
1. Tạo mới Bệnh nhân và Bác sĩ.
2. Đặt lịch khám (Appointment Service lưu `patient_id` và `doctor_id`).
3. Lấy thông tin lịch khám bằng cách thực hiện gọi dịch vụ chéo (cross-service resolution) để tổng hợp ra thông tin đầy đủ một cách mượt mà.
4. Thực hiện khám bệnh (Medical Record) và kê đơn bán thuốc (Pharmacy).