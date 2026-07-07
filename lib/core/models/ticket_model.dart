import 'trip_model.dart';

/// Model đại diện cho 1 vé xe khách đã mua thành công
class TicketModel {
  final String id;
  final String userId;        // ID người dùng mua vé
  final String tripId;        // ID chuyến xe
  final List<String> seats;   // Các ghế đã mua (VD: ['A1', 'A2'])
  final double totalPrice;    // Tổng tiền thanh toán
  final DateTime bookingDate; // Thời điểm đặt vé

  // Lưu trữ lại các thông tin cơ bản của chuyến xe để lỡ chuyến xe bị xóa,
  // lịch sử vé của khách vẫn hiển thị đúng.
  final String busNumber;
  final String departure;
  final String destination;
  final String departureDate; // e.g., '02/07/2026'
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String status; // 'booked', 'cancelled', 'completed'

  TicketModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.seats,
    required this.totalPrice,
    required this.bookingDate,
    required this.busNumber,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    this.status = 'booked',
  });

  /// Parse dữ liệu từ Firestore JSON map về Object TicketModel
  factory TicketModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return TicketModel(
      id: docId,
      userId: data['userId'] ?? '',
      tripId: data['tripId'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      bookingDate: data['bookingDate'] != null 
          ? DateTime.parse(data['bookingDate']) 
          : DateTime.now(),
      busNumber: data['busNumber'] ?? '',
      departure: data['departure'] ?? '',
      destination: data['destination'] ?? '',
      departureDate: data['departureDate'] ?? '',
      departureTime: data['departureTime'] ?? '',
      arrivalTime: data['arrivalTime'] ?? '',
      duration: data['duration'] ?? '',
      status: data['status'] ?? 'booked',
    );
  }

  /// Map Object TicketModel thành JSON để lưu lên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tripId': tripId,
      'seats': seats,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate.toIso8601String(),
      'busNumber': busNumber,
      'departure': departure,
      'destination': destination,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'status': status,
    };
  }

  /// Tiện ích copy thông tin từ TripModel sang TicketModel khi tạo vé mới
  factory TicketModel.createFromTrip({
    required TripModel trip,
    required String userId,
    required List<String> selectedSeats,
    required double totalPrice,
    required String departureDate,
  }) {
    return TicketModel(
      id: '', // Firebase sẽ tự sinh ID
      userId: userId,
      tripId: trip.id,
      seats: selectedSeats,
      totalPrice: totalPrice,
      bookingDate: DateTime.now(),
      busNumber: trip.busNumber,
      departure: trip.departure,
      destination: trip.destination,
      departureDate: departureDate,
      departureTime: trip.departureTime,
      arrivalTime: trip.arrivalTime,
      duration: trip.duration,
      status: 'booked',
    );
  }
}
