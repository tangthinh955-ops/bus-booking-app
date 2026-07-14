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

## [08/07/2026] — Việc: Xây dựng Admin Dashboard (Quản lý chuyến & vé)
- **Đã làm:** 
  - (Bước 1-4) Hoàn thành CRUD `TripService`, `AdminController` và giao diện `TripsTab`, `TripFormScreen`. Hỗ trợ thêm/sửa/xóa chuyến xe trực tiếp lên Firestore. Thêm thanh tìm kiếm client-side.
  - (Bước 5) Xây dựng `BookingsTab` đọc dữ liệu vé thực tế từ Firestore thông qua `AdminController`. Thêm chức năng lọc trạng thái vé (`booked`, `cancelled`, `completed`) và cập nhật trạng thái vé.
  - (Sửa lỗi crash) Chuyển `BookingsTab` từ `GetView` sang `StatefulWidget` để lưu instance của controller một lần vào `initState`, tránh lỗi lifecycle của GetX khi render widget trong một `static const List`. Sửa lỗi an toàn cho UI: đổi `Rx<String?>(null)` thành `Rxn<String>()` và fix `substring` ID để tránh `RangeError`.
  - Cập nhật chuẩn hóa Navigation: 100% sử dụng `Get.to()`, `Get.back()` thay vì `Navigator.of(context)` để tránh lỗi context bị mất.
- **Đang làm/Vướng mắc:** Đã khắc phục xong lỗi crash. Chuẩn bị thực hiện Bước 6: Thống kê doanh thu (`OverviewTab`) và Bước 7: Tính năng Hủy vé bên phía Customer.
- **Quyết định đã chốt:** Đối với quy mô một nhà xe nhỏ/vừa, lấy toàn bộ danh sách Trips và Tickets về rồi dùng local filter trên Client (`AdminController.filteredTrips`, `.filteredTickets`) thay vì query phức tạp trên Firestore để tránh phải tạo Composite Indexes (trừ phi dữ liệu sau này phình to quá lớn).

## [09/07/2026] — Việc: Hoàn thiện Admin Dashboard & Tính năng Hủy vé
- **Đã làm:** 
  - Sửa `OverviewTab` (Admin Dashboard) để hiển thị thống kê thực (doanh thu, số lượng vé, số vé đang chờ) trực tiếp từ Firebase thay vì dữ liệu giả. Đồng bộ chuẩn màu sắc (Cam - Đang chờ, Xanh lá - Hoàn thành, Đỏ - Đã hủy).
  - Thêm tính năng **Hủy vé (Customer)**: Dùng Firestore Transaction (`ticket_service.dart`) để đảm bảo vừa đổi trạng thái vé sang 'cancelled', vừa cộng lại số lượng ghế trống (`availableSeats`) cho chuyến xe một cách an toàn.
  - Bổ sung **điều kiện 2 tiếng**: Khách hàng chỉ được phép hủy vé trước giờ khởi hành ít nhất 2 tiếng (`ticket_detail_screen.dart`). Xử lý triệt để lỗi điều hướng và làm mới lại danh sách `HistoryTab` ngay sau khi hủy.
  - Cải tiến định dạng ID vé trên Firestore: Bỏ ID random tự động của Firebase, chuyển sang dạng **`TK-<thời gian mili-giây>`** (ví dụ `TK-1783609131839`) để dễ quản lý và tự động sắp xếp theo thời gian trên cơ sở dữ liệu.
- **Quyết định đã chốt:** Giữ định dạng custom ID `TK-timestamp` vì quy mô app cho phép ID sinh ra từ phía client dựa trên thời gian thực (ít khả năng đụng độ) và cực kì thân thiện cho việc vận hành/tìm lỗi thủ công.

## [14/07/2026] — Việc: Xử lý logic đặt vé theo ngày & Nâng cấp Sơ đồ ghế
- **Đã làm:**
  - Cải tiến logic đặt vé: Chuyển đổi từ cơ chế lưu số ghế cứng trong `TripModel` sang lưu trữ theo ngày thông qua collection `tickets` (Dùng `TicketService.getBookedSeats(tripId, date)`). Khắc phục triệt để lỗi "vé bị dính sang ngày khác".
  - Nâng cấp `SeatSelectionScreen`: 
    - Phân chia 2 tầng cho xe Giường nằm 34 chỗ (hiển thị UI Tầng dưới B / Tầng trên A sử dụng custom Tabs).
    - Cập nhật định dạng ghế cho xe thường 34 chỗ (chung 1 sơ đồ nhưng nửa đầu A, nửa đuôi B).
    - Xe Limousine 9 chỗ giữ nguyên sơ đồ 1 tầng với 100% prefix A.
  - Chỉnh sửa dữ liệu gốc (Seed Data): Cập nhật toàn bộ các tuyến "Giường nằm 40 chỗ" thành "Giường nằm 34 chỗ" để sát với thực tế. Tạo/xóa tool khôi phục dữ liệu trên Firebase để đồng bộ hóa seed data.
- **Đang làm/Vướng mắc:** Tạm thời đã giải quyết xong các nhu cầu cấp bách.
- **Quyết định đã chốt:** Logic phân tầng và mã hóa ghế ngồi (Prefix A, B) được code cứng ở Client (theo tính chất đặc thù của 3 loại xe) để tối ưu UI và giảm tải logic cấu hình trên Firestore.
