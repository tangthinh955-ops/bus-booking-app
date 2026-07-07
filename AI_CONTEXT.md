# AI_CONTEXT.md — App Đặt Vé Xe Khách Liên Tỉnh (Flutter)

> File này dùng để paste vào đầu mỗi phiên chat mới (Claude hoặc Gemini) để AI nắm ngữ cảnh ngay, không cần giải thích lại từ đầu. Kèm theo phần Nhật ký ở cuối để AI biết đang làm tới đâu.

## 1. Mục tiêu dự án
- App đặt vé xe khách liên tỉnh cho thị trường Việt Nam.
- 2 luồng người dùng: Hành khách (tìm chuyến, chọn ghế, đặt vé) và Admin (quản lý chuyến, tuyến, xe).

## 2. Tech stack
- **Frontend:** Flutter / Dart
- **Quản lý trạng thái (State Management) & Điều hướng (Routing):** GetX (Sử dụng `GetMaterialApp`, `GetxController`, `.obs`, `Get.to()`, `Get.offAll()`,...)
- **Backend/API:** Firebase (Sử dụng `firebase_auth` để đăng nhập/đăng ký và `cloud_firestore` để lưu trữ dữ liệu database). Không dùng Node.js/API ngoài.

## 3. Cấu trúc thư mục
Dự án áp dụng cấu trúc Feature-first, tách role rõ ràng. Code chính nằm trong `lib/features/`:
- `auth/`: Chứa các logic và màn hình xác thực (Đăng nhập, Đăng ký).
- `customer/`: Dành cho role Khách hàng (Hành khách). Bao gồm các sub-feature: `home`, `booking`, `tickets`, `profile`.
- `admin/`: Dành cho role Admin. Bao gồm các sub-feature: `dashboard`, `manage_routes`, `manage_buses`, `manage_bookings`.

## 4. Các màn hình đã có 
* **Xác thực (Auth):**
  - Đăng nhập (`login_screen`)
  - Đăng ký (`register_screen`)

* **Khách hàng (Customer):**
  - Trang chủ (`home`)
  - Luồng đặt vé (`booking`: tìm kiếm, chi tiết chuyến, chọn ghế)
  - Quản lý vé của tôi (`tickets`)
  - Hồ sơ cá nhân (`profile`)

* **Admin:**
  - Bảng điều khiển (`dashboard`)
  - Quản lý Tuyến xe (`manage_routes`)
  - Quản lý Xe (`manage_buses`)
  - Quản lý Đặt vé (`manage_bookings`)

## 5. Quy ước code / ràng buộc quan trọng
- **BẮT BUỘC** dùng GetX cho State Management và Navigation. Không tự ý đề xuất dùng Provider, Bloc hay `Navigator.push`.
- **BẮT BUỘC** dùng Firebase Firestore cho Database. Các hàm thêm/sửa/xóa phải giao tiếp qua Firestore.
- Giao diện tách nhỏ widget nếu quá dài. Tuân thủ Material Design.

## 6. Lưu ý khi dùng nhiều AI (Claude + Gemini)
- File này là nguồn sự thật duy nhất về kiến trúc — nếu 1 AI đề xuất đổi kiến trúc/thư viện, đối chiếu với file này trước khi chấp nhận.
- Khi 2 AI đưa ra cách làm khác nhau cho cùng 1 vấn đề, ghi lại vào PROGRESS (Nhật ký) cách đã chọn và lý do, để lần sau không hỏi lại từ đầu.

---

# NHẬT KÝ TIẾN ĐỘ (PROGRESS)

> Mỗi lần code xong 1 buổi, ghi nhanh 3 dòng: đã làm gì / đang vướng gì / quyết định gì.
> Mở chat mới thì paste nội dung từ đầu file đến hết phần "Nhật ký mới nhất" (không cần paste những ngày quá cũ) để AI bắt kịp ngay.

## [07/07/2026] — Việc: Cấu hình chuẩn bị dự án
- **Đã làm:** Hoàn thiện sơ bộ UI luồng Đăng nhập, Đăng ký. Thiết lập Firebase và GetX. Dựng khung thư mục theo chuẩn feature-first.
- **Đang làm/Vướng mắc:** Đang chuẩn bị phát triển các tính năng tiếp theo.
- **Quyết định đã chốt:** Tách bạch 2 luồng Customer và Admin. Sử dụng GetX để routing và quản lý state.

## [07/07/2026] (Phiên 2) — Việc: Nâng cấp trải nghiệm Đặt vé & Tìm kiếm
- **Đã làm:** 
  - Hoàn thiện UI trang Chi tiết vé (`TicketDetailScreen`) với QR code và trạng thái màu sắc.
  - Tối ưu hóa UI/UX trang Chủ (`HomeTab`): thêm BottomSheet chọn Tỉnh/Thành có thanh tìm kiếm, DatePicker (cấu hình `flutter_localizations` để fix lỗi không hiện lịch), hiệu ứng loading Shimmer, và thanh cuộn ngày ngang tự động canh giữa (Auto-scroll).
- **Đang làm/Vướng mắc:** Chuẩn bị sang Bước 3: Làm tính năng Chỉnh sửa thông tin cá nhân (`ProfileTab`) kết nối với Firestore.
- **Quyết định đã chốt:** Giữ trạng thái trang Chủ (Home) rỗng lúc đầu để hướng người dùng chủ động điền form tìm kiếm chuyến. Giao diện mượt mà theo chuẩn app thương mại.

## [07/07/2026] (Phiên 3) — Việc: Hoàn thiện luồng Cá nhân & Thông báo
- **Đã làm:** 
  - (Bước 3) Hoàn thiện cập nhật thông tin cá nhân.
  - (Bước 4) Xây dựng tính năng Đổi mật khẩu (Re-authenticate với Firebase trước khi đổi).
  - (Bước 5) Xây dựng Tab Thông báo tự động: Dùng `NotificationService` phân tích lịch sử vé (`TicketService`) để tự động sinh ra các thông báo (Thanh toán, Nhắc 4 tiếng, 1 tiếng, 10 phút) thay vì lưu riêng thông báo trên DB.
  - Cập nhật Data Model: Thêm trường `departureDate` vào `TicketModel` để lưu trữ ngày khởi hành (trước đó chỉ lưu giờ).
  - Tinh chỉnh giao diện: Thu nhỏ ngày mua vé trên `HistoryTab`, thay thế ngày mua thành "Giờ xuất bến" trên `TicketDetailScreen`, và xử lý mượt mà dữ liệu vé cũ thiếu ngày.
- **Đang làm/Vướng mắc:** Hoàn thành xong luồng người dùng (Customer). Chuẩn bị chuyển sang phát triển phần Quản trị viên (Admin Dashboard).
- **Quyết định đã chốt:** Thông báo tự sinh (auto-generated) từ Client dựa trên danh sách vé để tiết kiệm query/lưu trữ Firestore. Dữ liệu vé cũ (không có `departureDate`) được fallback bằng logic hiển thị chuỗi rỗng để không lỗi giao diện.
