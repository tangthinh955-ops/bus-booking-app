import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/ticket_model.dart';
import '../controllers/admin_controller.dart';

class AdminNotificationsScreen extends GetView<AdminController> {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: AppColors.adminPrimary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        final List<TicketModel> allBookings = controller.tickets.toList();

        // Sắp xếp các đơn đặt vé theo thời gian mới nhất
        allBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

        if (allBookings.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có thông báo nào.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allBookings.length,
          itemBuilder: (context, index) {
            final ticket = allBookings[index];
            return _buildNotificationCard(ticket);
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(TicketModel ticket) {
    // Trạng thái đơn để hiển thị màu sắc và text
    final bool isCancelled = ticket.status == 'cancelled';
    final bool isCompleted = ticket.status == 'completed';

    final Color statusColor = isCancelled
        ? Colors.red
        : (isCompleted ? Colors.green : Colors.orange);

    final String actionText = isCancelled
        ? 'vừa HỦY'
        : (isCompleted ? 'đã HOÀN THÀNH' : 'vừa ĐẶT MỚI');

    // Format ngày đặt
    final String timeStr = DateFormat(
      'HH:mm - dd/MM/yyyy',
    ).format(ticket.bookingDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            isCancelled ? Icons.cancel_outlined : Icons.directions_bus_outlined,
            color: statusColor,
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Khách hàng '),
              TextSpan(
                text:
                    '(ID: ${ticket.userId.length >= 5 ? ticket.userId.substring(0, 5).toUpperCase() : ticket.userId.toUpperCase()})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' $actionText chuyến '),
              TextSpan(
                text: '${ticket.departure} - ${ticket.destination}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' (Ngày đi: ${ticket.departureDate}).'),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${ticket.id}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                timeStr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
