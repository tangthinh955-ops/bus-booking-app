/// Model đại diện cho một CHUYẾN XE của hãng.
///
/// Vì đây là app của 1 hãng xe duy nhất (kiểu Futa Bus, Phương Trang),
/// không cần lưu tên hãng — thay vào đó lưu số hiệu xe/biển số.
class TripModel {
  final String id;            // Mã chuyến (dùng để phân biệt)
  final String busNumber;     // Số hiệu xe (VD: "AP-01", "AP-Limousine-02")
  final String busType;       // Loại xe (VD: "Limousine 9 chỗ", "Giường nằm 40 chỗ")
  final String departure;     // Điểm đi (VD: "TP. Hồ Chí Minh")
  final String destination;   // Điểm đến (VD: "Đà Lạt")
  final String departureTime; // Giờ khởi hành (VD: "07:00")
  final String arrivalTime;   // Giờ đến dự kiến (VD: "13:00")
  final String duration;      // Thời gian hành trình (VD: "6 tiếng")
  final double price;         // Giá vé (VNĐ)
  final int totalSeats;       // Tổng số ghế
  final int availableSeats;   // Số ghế còn trống
  final List<String> amenities; // Tiện ích (VD: ["WiFi", "Điều hoà", "Nước uống"])

  const TripModel({
    required this.id,
    required this.busNumber,
    required this.busType,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.amenities,
  });

  /// Còn chỗ hay không
  bool get hasAvailableSeats => availableSeats > 0;

  /// Sắp hết chỗ (còn <= 5)
  bool get isAlmostFull => availableSeats > 0 && availableSeats <= 5;

  /// Số ghế đã được đặt
  int get bookedSeats => totalSeats - availableSeats;

  /// Danh sách các điểm đi duy nhất (dùng cho dropdown tìm kiếm)
  static List<String> get popularCities => [
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        'Nha Trang',
        'Phan Thiết',
        'Cần Thơ',
        'Đà Nẵng',
        'Hội An',
        'Huế',
      ];
}
