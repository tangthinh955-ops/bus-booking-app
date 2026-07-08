import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../core/models/ticket_model.dart';
import '../core/models/trip_model.dart';

class TicketService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thực hiện luồng đặt vé:
  /// 1. Kiểm tra lại xem ghế còn trống không (Transaction).
  /// 2. Giảm availableSeats của chuyến xe và thêm mã ghế vào bookedSeatsList.
  /// 3. Lưu thông tin vé mới vào collection `tickets`.
  Future<bool> bookTicket({
    required TripModel trip,
    required String userId,
    required List<String> selectedSeats,
    required double totalPrice,
    required String departureDate,
  }) async {
    final tripRef = _firestore.collection('trips').doc(trip.id);
    final ticketRef = _firestore.collection('tickets').doc(); // Tự sinh ID cho vé

    try {
      await _firestore.runTransaction((transaction) async {
        // Đọc dữ liệu chuyến xe hiện tại
        final tripDoc = await transaction.get(tripRef);
        if (!tripDoc.exists) {
          throw Exception('Chuyến xe không tồn tại.');
        }

        final currentTrip = TripModel.fromFirestore(tripDoc.data()!, tripDoc.id);

        // Kiểm tra xem có ghế nào trong danh sách đã bị người khác đặt chưa
        for (String seat in selectedSeats) {
          if (currentTrip.bookedSeatsList.contains(seat)) {
            throw Exception('Ghế $seat đã có người đặt, vui lòng chọn ghế khác!');
          }
        }

        // Tính toán số ghế còn lại
        final newAvailableSeats = currentTrip.availableSeats - selectedSeats.length;
        if (newAvailableSeats < 0) {
          throw Exception('Chuyến xe không đủ số ghế trống!');
        }

        // Cập nhật mảng ghế đã đặt
        final updatedBookedSeats = List<String>.from(currentTrip.bookedSeatsList)..addAll(selectedSeats);

        // Tạo thông tin vé
        final ticket = TicketModel.createFromTrip(
          trip: currentTrip,
          userId: userId,
          selectedSeats: selectedSeats,
          totalPrice: totalPrice,
          departureDate: departureDate,
        );

        // Ghi dữ liệu vào database (Cập nhật chuyến xe & Lưu vé)
        transaction.update(tripRef, {
          'availableSeats': newAvailableSeats,
          'bookedSeatsList': updatedBookedSeats,
        });

        transaction.set(ticketRef, ticket.toFirestore());
      });

      return true; // Giao dịch thành công
    } catch (e) {
      Get.snackbar('Lỗi đặt vé', e.toString());
      return false; // Giao dịch thất bại
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
