import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../core/models/ticket_model.dart';
import '../core/models/trip_model.dart';

class TicketService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách các ghế đã được đặt cho một chuyến xe trong một ngày cụ thể
  Future<List<String>> getBookedSeats(String tripId, String departureDate) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tripId', isEqualTo: tripId)
          .where('departureDate', isEqualTo: departureDate)
          .get();

      final List<String> bookedSeats = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['status'] != 'cancelled') {
          final seats = List<String>.from(data['seats'] ?? []);
          bookedSeats.addAll(seats);
        }
      }
      return bookedSeats;
    } catch (e) {
      print('Lỗi lấy ghế đã đặt: $e');
      return [];
    }
  }

  /// Thực hiện luồng đặt vé:
  /// 1. Tính toán lại ghế động qua `getBookedSeats`
  /// 2. Lưu thông tin vé mới vào collection `tickets`.
  /// KHÔNG cập nhật fixed data trên `TripModel` nữa.
  Future<bool> bookTicket({
    required TripModel trip,
    required String userId,
    required List<String> selectedSeats,
    required double totalPrice,
    required String departureDate,
  }) async {
    // Tạo ID dễ đọc cho vé: TK- + timestamp (ví dụ: TK-1783609131839)
    final customTicketId = 'TK-${DateTime.now().millisecondsSinceEpoch}';
    final ticketRef = _firestore.collection('tickets').doc(customTicketId);

    try {
      // 1. Kiểm tra lại xem ghế còn trống không (Dynamic)
      final bookedSeats = await getBookedSeats(trip.id, departureDate);
      
      for (String seat in selectedSeats) {
        if (bookedSeats.contains(seat)) {
          throw Exception('Ghế $seat đã có người đặt trong ngày này, vui lòng chọn ghế khác!');
        }
      }

      // 2. Tạo thông tin vé
      final ticket = TicketModel.createFromTrip(
        trip: trip,
        userId: userId,
        selectedSeats: selectedSeats,
        totalPrice: totalPrice,
        departureDate: departureDate,
      );

      // 3. Ghi dữ liệu vào database (Chỉ Lưu vé, không sửa TripModel)
      await ticketRef.set(ticket.toFirestore());

      return true; // Đặt vé thành công
    } catch (e) {
      Get.snackbar('Lỗi đặt vé', e.toString());
      return false; // Đặt vé thất bại
    }
  }

  /// Khách hàng hủy vé
  /// Chỉ cập nhật trạng thái vé thành 'cancelled'
  Future<String?> cancelTicket({
    required String ticketId,
    required String tripId,
    required List<String> seatsToCancel,
  }) async {
    final ticketRef = _firestore.collection('tickets').doc(ticketId);

    try {
      // Lấy thông tin vé
      final ticketDoc = await ticketRef.get();
      if (!ticketDoc.exists) {
        throw Exception('Vé không tồn tại.');
      }

      final currentStatus = ticketDoc.data()?['status'] ?? 'booked';
      if (currentStatus == 'cancelled') {
        throw Exception('Vé này đã được hủy trước đó.');
      }

      // Thực thi cập nhật vé
      await ticketRef.update({
        'status': 'cancelled',
      });

      return null; // Thành công
    } catch (e) {
      print('Lỗi hủy vé: $e');
      return e.toString().replaceAll('Exception: ', ''); // Trả về thông báo lỗi
    }
  }

  /// Lấy danh sách lịch sử vé của một người dùng (dành cho Customer)
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();

      final tickets = snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sắp xếp trên Dart để tránh lỗi thiếu Composite Index của Firestore
      tickets.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      return tickets;
    } catch (e) {
      print('Lỗi tải lịch sử vé: $e');
      return [];
    }
  }

  /// Lấy TOÀN BỘ vé trên hệ thống (dành cho Admin xem và quản lý)
  ///
  /// Không lọc theo userId — Admin có quyền thấy tất cả đơn của mọi khách.
  Future<List<TicketModel>> getAllTickets() async {
    try {
      final snapshot = await _firestore.collection('tickets').get();

      final tickets = snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sắp xếp mới nhất lên đầu
      tickets.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      return tickets;
    } catch (e) {
      print('Lỗi tải toàn bộ vé: $e');
      return [];
    }
  }

  /// Cập nhật trạng thái của một vé (Admin dùng để xác nhận hoặc huỷ)
  ///
  /// [ticketId]: document ID của vé cần cập nhật.
  /// [newStatus]: trạng thái mới, ví dụ 'booked', 'cancelled', 'completed'.
  Future<void> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await _firestore
          .collection('tickets')
          .doc(ticketId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái vé: $e');
    }
  }
}
