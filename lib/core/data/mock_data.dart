import '../models/trip_model.dart';

/// Dữ liệu giả (Mock Data) — Tất cả chuyến đều thuộc hãng "An Phát Bus".
/// Tập trung vào các TUYẾN ĐƯỜNG khác nhau của hãng.
/// Sau này thay bằng API thật, xóa file này là xong.
class MockData {
  static final List<TripModel> trips = [
    // ── TUYẾN HCM → ĐÀ LẠT ─────────────────────────────────────────
    const TripModel(
      id: 'trip_001',
      busNumber: 'AP-L01',
      busType: 'Limousine 9 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Đà Lạt',
      departureTime: '07:00',
      arrivalTime: '13:00',
      duration: '6 tiếng',
      price: 280000,
      totalSeats: 9,
      availableSeats: 4,
      amenities: ['WiFi', 'Điều hoà', 'Nước uống', 'Chăn gối'],
    ),
    const TripModel(
      id: 'trip_002',
      busNumber: 'AP-G01',
      busType: 'Giường nằm 40 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Đà Lạt',
      departureTime: '22:00',
      arrivalTime: '05:00',
      duration: '7 tiếng',
      price: 200000,
      totalSeats: 40,
      availableSeats: 18,
      amenities: ['WiFi', 'Điều hoà', 'Chăn gối'],
    ),

    // ── TUYẾN HCM → NHA TRANG ───────────────────────────────────────
    const TripModel(
      id: 'trip_003',
      busNumber: 'AP-L02',
      busType: 'Limousine 9 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Nha Trang',
      departureTime: '08:00',
      arrivalTime: '16:00',
      duration: '8 tiếng',
      price: 320000,
      totalSeats: 9,
      availableSeats: 2,  // Sắp hết chỗ
      amenities: ['WiFi', 'Điều hoà', 'Nước uống', 'Bữa ăn nhẹ'],
    ),
    const TripModel(
      id: 'trip_004',
      busNumber: 'AP-G02',
      busType: 'Ghế ngồi VIP 34 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Nha Trang',
      departureTime: '20:30',
      arrivalTime: '04:30',
      duration: '8 tiếng',
      price: 240000,
      totalSeats: 34,
      availableSeats: 0,  // Hết chỗ
      amenities: ['Điều hoà', 'Chăn gối'],
    ),

    // ── TUYẾN HCM → PHAN THIẾT ──────────────────────────────────────
    const TripModel(
      id: 'trip_005',
      busNumber: 'AP-G03',
      busType: 'Ghế ngồi VIP 34 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Phan Thiết',
      departureTime: '06:30',
      arrivalTime: '10:30',
      duration: '4 tiếng',
      price: 150000,
      totalSeats: 34,
      availableSeats: 20,
      amenities: ['Điều hoà', 'Nước uống'],
    ),

    // ── TUYẾN HCM → CẦN THƠ ────────────────────────────────────────
    const TripModel(
      id: 'trip_006',
      busNumber: 'AP-G04',
      busType: 'Ghế ngồi 45 chỗ',
      departure: 'TP. Hồ Chí Minh',
      destination: 'Cần Thơ',
      departureTime: '09:00',
      arrivalTime: '12:30',
      duration: '3.5 tiếng',
      price: 120000,
      totalSeats: 45,
      availableSeats: 30,
      amenities: ['Điều hoà'],
    ),
  ];

  /// Lấy danh sách tuyến đường duy nhất (Điểm đi → Điểm đến)
  static List<Map<String, String>> get popularRoutes {
    final Set<String> seen = {};
    final List<Map<String, String>> routes = [];
    for (final trip in trips) {
      final key = '${trip.departure}→${trip.destination}';
      if (!seen.contains(key)) {
        seen.add(key);
        routes.add({
          'departure': trip.departure,
          'destination': trip.destination,
        });
      }
    }
    return routes;
  }

  /// Lọc chuyến xe theo điểm đi và điểm đến
  static List<TripModel> searchTrips({
    required String departure,
    required String destination,
  }) {
    return trips.where((t) =>
      t.departure == departure && t.destination == destination
    ).toList();
  }
}
