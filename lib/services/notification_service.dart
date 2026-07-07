import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'ticket_service.dart';

class NotificationService extends GetxService {
  final TicketService _ticketService = Get.find<TicketService>();

  /// Sinh danh sách thông báo tự động dựa trên lịch sử đặt vé
  Future<List<Map<String, String>>> getNotifications(String userId) async {
    final tickets = await _ticketService.getUserTickets(userId);
    final List<Map<String, String>> notifications = [];
    final now = DateTime.now();

    for (var ticket in tickets) {
      // 1. Thông báo thanh toán thành công
      notifications.add({
        'title': 'Thanh toán thành công!',
        'body': 'Thanh toán ${_formatPrice(ticket.totalPrice)}đ thành công. Mã vé: ${ticket.id}.',
        'time': _formatTime(ticket.bookingDate),
        'timestamp': ticket.bookingDate.millisecondsSinceEpoch.toString(),
        'icon': 'check_circle',
      });

      // Lấy thời gian khởi hành thực tế
      DateTime? departureTime = _parseDepartureTime(ticket.departureDate, ticket.departureTime);
      if (departureTime != null) {
        // Mốc 4 tiếng trước giờ chạy
        final fourHoursBefore = departureTime.subtract(const Duration(hours: 4));
        if (now.isAfter(fourHoursBefore)) {
          notifications.add({
            'title': 'Sắp đến giờ khởi hành!',
            'body': 'Chuyến xe đi ${ticket.destination} của bạn sẽ khởi hành lúc ${ticket.departureTime}. Đừng quên chuẩn bị hành lý nhé!',
            'time': _formatTime(fourHoursBefore),
            'timestamp': fourHoursBefore.millisecondsSinceEpoch.toString(),
            'icon': 'notifications_active',
          });
        }

        // Mốc 1 tiếng trước giờ chạy
        final oneHourBefore = departureTime.subtract(const Duration(hours: 1));
        if (now.isAfter(oneHourBefore)) {
          notifications.add({
            'title': 'Sắp khởi hành!',
            'body': 'Chỉ còn 1 tiếng nữa là xe chạy. Vui lòng có mặt tại điểm đón trước 15 phút để lên xe.',
            'time': _formatTime(oneHourBefore),
            'timestamp': oneHourBefore.millisecondsSinceEpoch.toString(),
            'icon': 'notifications_active',
          });
        }

        // Mốc 10 phút trước giờ chạy
        final tenMinutesBefore = departureTime.subtract(const Duration(minutes: 10));
        if (now.isAfter(tenMinutesBefore)) {
          notifications.add({
            'title': 'Xe chuẩn bị xuất bến!',
            'body': 'Chuyến xe của bạn sẽ lăn bánh trong 10 phút nữa. Vui lòng di chuyển ra xe ngay.',
            'time': _formatTime(tenMinutesBefore),
            'timestamp': tenMinutesBefore.millisecondsSinceEpoch.toString(),
            'icon': 'directions_bus',
          });
        }
      }
    }

    // Sắp xếp thông báo mới nhất lên đầu (dựa theo timestamp)
    notifications.sort((a, b) {
      final tA = int.tryParse(a['timestamp'] ?? '0') ?? 0;
      final tB = int.tryParse(b['timestamp'] ?? '0') ?? 0;
      return tB.compareTo(tA);
    });

    return notifications;
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua lúc ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(time);
    }
  }

  /// Parse string "dd/MM/yyyy" và "HH:mm" thành DateTime
  DateTime? _parseDepartureTime(String dateStr, String timeStr) {
    try {
      // dateStr: "02/07/2026"
      // timeStr: "07:00"
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final timeParts = timeStr.split(':');
      if (timeParts.length != 2) return null;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}
