import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../core/models/trip_model.dart';

/// Service xử lý toàn bộ việc đọc/ghi chuyến xe từ Firestore.
/// Thay thế hoàn toàn MockData sau khi dữ liệu đã được seed lên Firebase.
class TripService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── ĐỌC DỮ LIỆU ─────────────────────────────────────────────────────
  //
  // Tập hợp các hàm chỉ đọc (query) dữ liệu từ Firestore, không thay đổi DB.

  /// Lấy tất cả chuyến xe (dành cho Admin xem toàn bộ)
  Future<List<TripModel>> getAllTrips() async {
    final snapshot = await _firestore
        .collection('trips')
        .orderBy('departureTime')
        .get();

    return snapshot.docs
        .map((doc) => TripModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Tìm kiếm chuyến xe theo điểm đi và điểm đến
  Future<List<TripModel>> searchTrips({
    required String departure,
    required String destination,
  }) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('departure', isEqualTo: departure)
        .where('destination', isEqualTo: destination)
        .get();

    final trips = snapshot.docs
        .map((doc) => TripModel.fromFirestore(doc.data(), doc.id))
        .toList();

    // Sắp xếp trên Dart để tránh lỗi thiếu Composite Index của Firestore
    trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return trips;
  }

  /// Lấy danh sách tuyến đường phổ biến (để hiển thị trang chủ)
  Future<List<TripModel>> getPopularTrips({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('availableSeats', isGreaterThan: 0)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => TripModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Lấy 1 chuyến xe theo ID
  Future<TripModel?> getTripById(String tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TripModel.fromFirestore(doc.data()!, doc.id);
  }

  // ── GHI DỮ LIỆU (CRUD) ──────────────────────────────────────────────
  //
  // Tập hợp các hàm thêm / sửa / xóa chuyến xe trên Firestore.
  // Admin Dashboard gọi các hàm này thông qua AdminController.

  /// Thêm một chuyến xe mới lên Firestore.
  ///
  /// Firestore sẽ tự sinh document ID; hàm trả về ID đó để dùng lại nếu cần.
  /// Ném [Exception] nếu ghi thất bại (ví dụ: mất mạng).
  Future<String> addTrip(TripModel trip) async {
    try {
      final docRef = await _firestore
          .collection('trips')
          .add(trip.toFirestore());
      return docRef.id; // Trả về ID vừa được Firestore tạo
    } catch (e) {
      throw Exception('Không thể thêm chuyến xe: $e');
    }
  }

  /// Thêm chuyến xe với ID do Admin tự đặt (VD: 'tp001', 'dl001').
  ///
  /// Dùng [.set()] thay vì [.add()] để chỉ định document ID cụ thể.
  /// Nếu ID đã tồn tại, Firestore sẽ **ghi đè** document cũ.
  Future<void> addTripWithId(TripModel trip) async {
    try {
      await _firestore.collection('trips').doc(trip.id).set(trip.toFirestore());
    } catch (e) {
      throw Exception('Không thể thêm chuyến xe: $e');
    }
  }

  /// Cập nhật thông tin một chuyến xe đã tồn tại trên Firestore.
  ///
  /// Dùng [trip.id] để xác định document cần sửa.
  /// Chỉ ghi đè các trường có trong [toFirestore()] — không xóa trường khác.
  Future<void> updateTrip(TripModel trip) async {
    try {
      await _firestore
          .collection('trips')
          .doc(trip.id)
          .update(trip.toFirestore());
    } catch (e) {
      throw Exception('Không thể cập nhật chuyến xe: $e');
    }
  }

  /// Xóa vĩnh viễn một chuyến xe khỏi Firestore theo [tripId].
  ///
  /// Lưu ý: Hành động này không hoàn tác được.
  /// Nên kiểm tra xem chuyến có vé đang hoạt động không trước khi gọi hàm này.
  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e) {
      throw Exception('Không thể xóa chuyến xe: $e');
    }
  }

  // ── SEED DỮ LIỆU MẪU ────────────────────────────────────────────────

  /// Ghi đè dữ liệu mẫu lên Firebase (chỉ đè các ID trùng, giữ nguyên các ID khác)
  Future<void> seedTripsToFirestore() async {
    final trips = _buildSeedData();

    // Dùng batch để ghi nhiều document cùng lúc (nhanh hơn ghi từng cái)
    final batch = _firestore.batch();

    for (final trip in trips) {
      final docRef = _firestore.collection('trips').doc(trip.id);
      batch.set(docRef, trip.toFirestore());
    }

    await batch.commit();
  }

  // ── DỮ LIỆU MẪU 10 TUYẾN ────────────────────────────────────────────
  List<TripModel> _buildSeedData() {
    return [
      // ── HCM → VŨNG TÀU (Gần ~2h, cách nhau 2 tiếng) ───────────────
      _trip(
        'tp001',
        'TP-G01',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '06:00',
        '08:00',
        '2 tiếng',
        120000,
        34,
        20,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'tp002',
        'TP-G02',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '08:00',
        '10:00',
        '2 tiếng',
        120000,
        34,
        15,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'tp003',
        'TP-G03',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '10:00',
        '12:00',
        '2 tiếng',
        120000,
        34,
        5,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'tp004',
        'TP-L01',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '12:00',
        '14:00',
        '2 tiếng',
        180000,
        9,
        3,
        ['WiFi', 'Điều hoà', 'Nước uống'],
      ),
      _trip(
        'tp005',
        'TP-G04',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '14:00',
        '16:00',
        '2 tiếng',
        120000,
        34,
        0,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'tp006',
        'TP-G05',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Vũng Tàu',
        '16:00',
        '18:00',
        '2 tiếng',
        120000,
        34,
        22,
        ['Điều hoà', 'Nước uống'],
      ),

      // ── HCM → PHAN THIẾT (~3.5h, cách nhau 3 tiếng) ────────────────
      _trip(
        'pt001',
        'TP-G06',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Phan Thiết',
        '06:00',
        '09:30',
        '3.5 tiếng',
        160000,
        34,
        18,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'pt002',
        'TP-G07',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Phan Thiết',
        '09:00',
        '12:30',
        '3.5 tiếng',
        160000,
        34,
        10,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'pt003',
        'TP-L02',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Phan Thiết',
        '12:00',
        '15:30',
        '3.5 tiếng',
        230000,
        9,
        4,
        ['WiFi', 'Điều hoà', 'Nước uống'],
      ),
      _trip(
        'pt004',
        'TP-G08',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Phan Thiết',
        '15:00',
        '18:30',
        '3.5 tiếng',
        160000,
        34,
        25,
        ['Điều hoà', 'Nước uống'],
      ),

      // ── HCM → ĐÀ LẠT (~6h, cách nhau 3 tiếng) ──────────────────────
      _trip(
        'dl001',
        'TP-L03',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        '05:00',
        '11:00',
        '6 tiếng',
        290000,
        9,
        2,
        ['WiFi', 'Điều hoà', 'Nước uống', 'Chăn gối'],
      ),
      _trip(
        'dl002',
        'TP-N01',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        '08:00',
        '14:00',
        '6 tiếng',
        210000,
        34,
        30,
        ['WiFi', 'Điều hoà', 'Chăn gối'],
      ),
      _trip(
        'dl003',
        'TP-L04',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        '11:00',
        '17:00',
        '6 tiếng',
        290000,
        9,
        7,
        ['WiFi', 'Điều hoà', 'Nước uống', 'Chăn gối'],
      ),
      _trip(
        'dl004',
        'TP-N02',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        '14:00',
        '20:00',
        '6 tiếng',
        210000,
        34,
        12,
        ['WiFi', 'Điều hoà', 'Chăn gối'],
      ),
      _trip(
        'dl005',
        'TP-N03',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Lạt',
        '22:00',
        '05:00',
        '7 tiếng',
        200000,
        34,
        18,
        ['Điều hoà', 'Chăn gối'],
      ),

      // ── HCM → NHA TRANG (~8h, 4 chuyến/ngày) ───────────────────────
      _trip(
        'nt001',
        'TP-L05',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Nha Trang',
        '05:00',
        '13:00',
        '8 tiếng',
        350000,
        9,
        1,
        ['WiFi', 'Điều hoà', 'Nước uống', 'Bữa ăn nhẹ'],
      ),
      _trip(
        'nt002',
        'TP-G12',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Nha Trang',
        '08:00',
        '16:00',
        '8 tiếng',
        260000,
        34,
        20,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'nt003',
        'TP-N04',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Nha Trang',
        '20:00',
        '04:00',
        '8 tiếng',
        240000,
        34,
        8,
        ['Điều hoà', 'Chăn gối'],
      ),
      _trip(
        'nt004',
        'TP-N05',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Nha Trang',
        '22:00',
        '06:00',
        '8 tiếng',
        240000,
        34,
        0,
        ['Điều hoà', 'Chăn gối'],
      ),

      // ── HCM → QUY NHƠN (~11h, 2 chuyến/ngày) ───────────────────────
      _trip(
        'qn001',
        'TP-N06',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Quy Nhơn',
        '17:00',
        '04:00',
        '11 tiếng',
        450000,
        34,
        15,
        ['WiFi', 'Điều hoà', 'Chăn gối'],
      ),
      _trip(
        'qn002',
        'TP-G16',
        'Ghế ngồi 34 chỗ',
        'TP. Hồ Chí Minh',
        'Quy Nhơn',
        '20:00',
        '07:00',
        '11 tiếng',
        400000,
        34,
        22,
        ['Điều hoà', 'Chăn gối'],
      ),

      // ── HCM → ĐÀ NẴNG (~16h, xe đêm) ──────────────────────────────
      _trip(
        'dn001',
        'TP-N07',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Nẵng',
        '17:00',
        '09:00',
        '16 tiếng',
        650000,
        34,
        10,
        ['WiFi', 'Điều hoà', 'Chăn gối', 'Bữa ăn nhẹ'],
      ),
      _trip(
        'dn002',
        'TP-N08',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Đà Nẵng',
        '19:00',
        '11:00',
        '16 tiếng',
        650000,
        34,
        28,
        ['WiFi', 'Điều hoà', 'Chăn gối', 'Bữa ăn nhẹ'],
      ),

      // ── HCM → CẦN THƠ (~3.5h, cách nhau 2.5 tiếng) ────────────────
      _trip(
        'ct001',
        'TP-G19',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cần Thơ',
        '05:30',
        '09:00',
        '3.5 tiếng',
        130000,
        45,
        35,
        ['Điều hoà'],
      ),
      _trip(
        'ct002',
        'TP-G20',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cần Thơ',
        '08:00',
        '11:30',
        '3.5 tiếng',
        130000,
        45,
        20,
        ['Điều hoà'],
      ),
      _trip(
        'ct003',
        'TP-G21',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cần Thơ',
        '10:30',
        '14:00',
        '3.5 tiếng',
        130000,
        45,
        40,
        ['Điều hoà'],
      ),
      _trip(
        'ct004',
        'TP-L06',
        'Limousine 9 chỗ',
        'TP. Hồ Chí Minh',
        'Cần Thơ',
        '13:00',
        '16:30',
        '3.5 tiếng',
        200000,
        9,
        5,
        ['WiFi', 'Điều hoà', 'Nước uống'],
      ),
      _trip(
        'ct005',
        'TP-G22',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cần Thơ',
        '15:30',
        '19:00',
        '3.5 tiếng',
        130000,
        45,
        30,
        ['Điều hoà'],
      ),

      // ── HCM → VĨNH LONG (~2.5h, cách nhau 3 tiếng) ─────────────────
      _trip(
        'vl001',
        'TP-G23',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Vĩnh Long',
        '06:00',
        '08:30',
        '2.5 tiếng',
        100000,
        45,
        30,
        ['Điều hoà'],
      ),
      _trip(
        'vl002',
        'TP-G24',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Vĩnh Long',
        '09:00',
        '11:30',
        '2.5 tiếng',
        100000,
        45,
        25,
        ['Điều hoà'],
      ),
      _trip(
        'vl003',
        'TP-G25',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Vĩnh Long',
        '12:00',
        '14:30',
        '2.5 tiếng',
        100000,
        45,
        0,
        ['Điều hoà'],
      ),
      _trip(
        'vl004',
        'TP-G26',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Vĩnh Long',
        '15:00',
        '17:30',
        '2.5 tiếng',
        100000,
        45,
        40,
        ['Điều hoà'],
      ),

      // ── HCM → CÀ MAU (~5h, 4 chuyến/ngày) ──────────────────────────
      _trip(
        'cm001',
        'TP-G27',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cà Mau',
        '05:00',
        '10:00',
        '5 tiếng',
        250000,
        45,
        20,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'cm002',
        'TP-N09',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Cà Mau',
        '08:30',
        '13:30',
        '5 tiếng',
        280000,
        34,
        12,
        ['Điều hoà', 'Chăn gối', 'Nước uống'],
      ),
      _trip(
        'cm003',
        'TP-G29',
        'Ghế ngồi 45 chỗ',
        'TP. Hồ Chí Minh',
        'Cà Mau',
        '12:00',
        '17:00',
        '5 tiếng',
        250000,
        45,
        35,
        ['Điều hoà', 'Nước uống'],
      ),
      _trip(
        'cm004',
        'TP-N10',
        'Giường nằm 34 chỗ',
        'TP. Hồ Chí Minh',
        'Cà Mau',
        '22:00',
        '03:00',
        '5 tiếng',
        270000,
        34,
        18,
        ['Điều hoà', 'Chăn gối'],
      ),
    ];
  }

  /// Helper tạo TripModel nhanh
  TripModel _trip(
    String id,
    String busNumber,
    String busType,
    String departure,
    String destination,
    String depTime,
    String arrTime,
    String duration,
    double price,
    int total,
    int available,
    List<String> amenities,
  ) {
    return TripModel(
      id: id,
      busNumber: busNumber,
      busType: busType,
      departure: departure,
      destination: destination,
      departureTime: depTime,
      arrivalTime: arrTime,
      duration: duration,
      price: price,
      totalSeats: total,
      availableSeats: total, // Đặt mặc định trống toàn bộ chỗ
      amenities: amenities,
    );
  }
}
