import 'package:get/get.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/trip_service.dart';

/// Controller quản lý toàn bộ state của khu vực Admin Dashboard.
///
/// Đây là nguồn dữ liệu duy nhất cho cả 4 tab Admin:
///   - OverviewTab  → dùng [trips] + [tickets] để tính thống kê
///   - TripsTab     → dùng [trips] để hiển thị danh sách chuyến xe
///   - BookingsTab  → dùng [tickets] để hiển thị danh sách đơn vé
///   - AccountTab   → không cần dữ liệu từ controller này
///
/// Mọi thao tác CRUD đều gọi vào [TripService] / [TicketService],
/// sau đó cập nhật lại list reactive để UI tự render lại qua Obx().
class AdminController extends GetxController {
  // ── KHỞI TẠO SERVICE ─────────────────────────────────────────────────

  final _tripService = Get.find<TripService>();
  final _ticketService = Get.find<TicketService>();

  // ── STATE (REACTIVE) ──────────────────────────────────────────────────

  /// Danh sách tất cả chuyến xe — dùng cho TripsTab
  final trips = <TripModel>[].obs;

  /// Danh sách tất cả vé — dùng cho BookingsTab và thống kê
  final tickets = <TicketModel>[].obs;

  /// Trạng thái loading chung (hiển thị spinner khi đang tải)
  final isLoading = false.obs;

  /// Từ khoá tìm kiếm chuyến xe (Admin gõ vào thanh search)
  final searchQuery = ''.obs;

  // ── THỐNG KÊ (COMPUTED) ───────────────────────────────────────────────
  //
  // Tính toán từ [trips] và [tickets] — không lưu riêng, luôn đồng bộ.

  /// Tổng số chuyến xe đang có
  int get totalTrips => trips.length;

  /// Tổng số ghế đã bán (từ các vé chưa bị hủy)
  int get totalSeatsSold => tickets
      .where((t) => t.status != 'cancelled')
      .fold(0, (sum, t) => sum + t.seats.length);

  /// Tổng doanh thu (chỉ tính vé thành công hoặc đã đi)
  double get totalRevenue => tickets
      .where((t) => t.status == 'booked' || t.status == 'completed')
      .fold(0.0, (sum, t) => sum + t.totalPrice);

  /// Số vé chờ xử lý (status == 'booked')
  int get pendingCount => tickets.where((t) => t.status == 'booked').length;

  /// Bộ lọc trạng thái vé cho BookingsTab.
  ///
  /// null = hiện tất cả; 'booked' | 'cancelled' | 'completed' = lọc theo trạng thái.
  /// Dùng Rxn<String> (nullable Rx) thay vì Rx<String?> để tương thích GetX tốt hơn.
  final ticketStatusFilter = Rxn<String>();

  /// Danh sách chuyến xe đã lọc theo [searchQuery].
  ///
  /// Tìm theo điểm đi HOẶC điểm đến (không phân biệt hoa thường).
  /// Nếu searchQuery rỗng → trả về toàn bộ danh sách.
  List<TripModel> get filteredTrips {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return trips;
    return trips.where((t) {
      return t.departure.toLowerCase().contains(query) ||
          t.destination.toLowerCase().contains(query) ||
          t.busNumber.toLowerCase().contains(query);
    }).toList();
  }

  /// Danh sách vé đã lọc theo [ticketStatusFilter], mới nhất lên trước.
  List<TicketModel> get filteredTickets {
    final filter = ticketStatusFilter.value;
    final list = filter == null
        ? List<TicketModel>.from(tickets)
        : tickets.where((t) => t.status == filter).toList();
    // Sắp xếp mới nhất lên đầu
    list.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return list;
  }

  // ── VÒNG ĐỜI CONTROLLER ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu ngay khi Admin Dashboard mở
    loadAll();
  }

  // ── TẢI DỮ LIỆU ──────────────────────────────────────────────────────

  /// Tải toàn bộ chuyến xe và vé từ Firestore cùng lúc.
  ///
  /// Dùng [Future.wait] để 2 request chạy song song, giảm thời gian chờ.
  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      // Chạy 2 request song song thay vì tuần tự
      final results = await Future.wait([
        _tripService.getAllTrips(),
        _ticketService.getAllTickets(),
      ]);

      trips.assignAll(results[0] as List<TripModel>);
      tickets.assignAll(results[1] as List<TicketModel>);
    } catch (e) {
      Get.snackbar(
        'Lỗi tải dữ liệu',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── CRUD CHUYẾN XE ────────────────────────────────────────────────────

  /// Thêm chuyến xe mới lên Firestore và cập nhật danh sách cục bộ.
  ///
  /// Trả về [true] nếu thành công, [false] nếu thất bại.
  Future<bool> addTrip(TripModel trip) async {
    try {
      String newId;
      if (trip.id.isEmpty) {
        // ID rỗng → để Firestore tự sinh ID
        final docRef = await _tripService.addTrip(trip);
        newId = docRef;
      } else {
        // Admin đã nhập ID tùy chỉnh → dùng luôn
        await _tripService.addTripWithId(trip);
        newId = trip.id;
      }

      final savedTrip = TripModel(
        id: newId,
        busNumber: trip.busNumber,
        busType: trip.busType,
        departure: trip.departure,
        destination: trip.destination,
        departureTime: trip.departureTime,
        arrivalTime: trip.arrivalTime,
        duration: trip.duration,
        price: trip.price,
        totalSeats: trip.totalSeats,
        availableSeats: trip.availableSeats,
        amenities: trip.amenities,
      );

      trips.add(savedTrip);
      return true; // TripFormScreen sẽ tự show snackbar + Get.back()
    } catch (e) {
      Get.snackbar(
        'Lỗi thêm chuyến',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Cập nhật thông tin chuyến xe trên Firestore và trong list cục bộ.
  Future<bool> updateTrip(TripModel trip) async {
    try {
      await _tripService.updateTrip(trip);

      final index = trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) trips[index] = trip;

      return true; // TripFormScreen sẽ tự show snackbar + Get.back()
    } catch (e) {
      Get.snackbar(
        'Lỗi cập nhật',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Xóa chuyến xe khỏi Firestore và khỏi list cục bộ.
  Future<bool> deleteTrip(String tripId) async {
    try {
      await _tripService.deleteTrip(tripId);

      // Xóa khỏi list local để UI cập nhật ngay, không cần reload
      trips.removeWhere((t) => t.id == tripId);

      Get.snackbar(
        'Đã xóa',
        'Chuyến xe đã được xóa thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // ── QUẢN LÝ VÉ ───────────────────────────────────────────────────────

  /// Cập nhật trạng thái vé trên Firestore và trong list cục bộ.
  ///
  /// Admin dùng để xác nhận ('booked' → không đổi) hoặc huỷ ('cancelled').
  /// [newStatus]: 'booked' | 'cancelled' | 'completed'
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await _ticketService.updateTicketStatus(ticketId, newStatus);

      // Cập nhật trực tiếp trong list để UI render lại không cần reload
      final index = tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final old = tickets[index];
        tickets[index] = TicketModel(
          id: old.id,
          userId: old.userId,
          tripId: old.tripId,
          seats: old.seats,
          totalPrice: old.totalPrice,
          bookingDate: old.bookingDate,
          busNumber: old.busNumber,
          departure: old.departure,
          destination: old.destination,
          departureDate: old.departureDate,
          departureTime: old.departureTime,
          arrivalTime: old.arrivalTime,
          duration: old.duration,
          status: newStatus, // Chỉ thay đổi trường này
        );
      }
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
