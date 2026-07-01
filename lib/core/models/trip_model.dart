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
  final List<String> bookedSeatsList; // Danh sách mã ghế đã đặt (Mới thêm)

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
    this.bookedSeatsList = const [],
  });

  /// Còn chỗ hay không
  bool get hasAvailableSeats => availableSeats > 0;

  /// Sắp hết chỗ (còn <= 5)
  bool get isAlmostFull => availableSeats > 0 && availableSeats <= 5;

  /// Số ghế đã được đặt
  int get bookedSeats => totalSeats - availableSeats;

  /// Tạo TripModel từ dữ liệu Firestore (Map → Object)
  factory TripModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return TripModel(
      id: docId,
      busNumber: data['busNumber'] ?? '',
      busType: data['busType'] ?? '',
      departure: data['departure'] ?? '',
      destination: data['destination'] ?? '',
      departureTime: data['departureTime'] ?? '',
      arrivalTime: data['arrivalTime'] ?? '',
      duration: data['duration'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      totalSeats: data['totalSeats'] ?? 0,
      availableSeats: data['availableSeats'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      bookedSeatsList: List<String>.from(data['bookedSeatsList'] ?? []),
    );
  }

  /// Chuyển TripModel sang Map để lưu lên Firestore (Object → Map)
  Map<String, dynamic> toFirestore() {
    return {
      'busNumber': busNumber,
      'busType': busType,
      'departure': departure,
      'destination': destination,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'amenities': amenities,
      'bookedSeatsList': bookedSeatsList,
    };
  }

  /// Danh sách thành phố hãng Thịnh Phát Bus phục vụ
  static List<String> get popularCities => [
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        'Phan Thiết',
        'Đà Lạt',
        'Nha Trang',
        'Quy Nhơn',
        'Đà Nẵng',
        'Cần Thơ',
        'Vĩnh Long',
        'Cà Mau',
      ];
}
