/// Trạng thái của một đơn đặt vé
enum BookingStatus {
  pending,   // Chờ xác nhận
  confirmed, // Đã xác nhận
  cancelled, // Đã huỷ
  completed, // Hoàn thành
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.cancelled:
        return 'Đã huỷ';
      case BookingStatus.completed:
        return 'Hoàn thành';
    }
  }
}

/// Model đại diện cho một ĐƠN ĐẶT VÉ do khách hàng tạo ra.
/// Admin dùng model này để xem, xác nhận hoặc huỷ đơn.
class BookingModel {
  final String id;             // Mã đơn đặt vé
  final String customerName;   // Tên khách hàng
  final String phone;          // SĐT khách hàng
  final String tripId;         // Liên kết tới TripModel.id
  final String route;          // VD: "TP. Hồ Chí Minh → Đà Lạt"
  final String departureTime;  // Giờ khởi hành
  final String bookingDate;    // Ngày đặt (VD: "01/07/2026")
  final int seatCount;         // Số ghế đã đặt
  final double totalPrice;     // Tổng tiền
  BookingStatus status;        // Trạng thái đơn (có thể thay đổi bởi admin)

  BookingModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.tripId,
    required this.route,
    required this.departureTime,
    required this.bookingDate,
    required this.seatCount,
    required this.totalPrice,
    this.status = BookingStatus.pending,
  });
}