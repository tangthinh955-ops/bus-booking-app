import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../booking/screens/ticket_detail_screen.dart';

/// Tab "Lịch sử" - hiển thị các vé đã đặt của người dùng
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _authService = Get.find<AuthService>();
  final _ticketService = Get.find<TicketService>();

  bool _isLoading = true;
  List<TicketModel> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      final tickets = await _ticketService.getUserTickets(userId);
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Chưa có lịch sử đặt vé',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final bool isCompleted =
            ticket.status == 'completed' || ticket.status == 'booked';
        final displayStatus = ticket.status == 'booked'
            ? 'Đã đặt'
            : (ticket.status == 'completed' ? 'Hoàn thành' : 'Đã hủy');

        final formattedDate = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(ticket.bookingDate);
        final formattedPrice =
            '${ticket.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias, // Để InkWell ripple không tràn ra ngoài
          child: InkWell(
            onTap: () async {
              await Get.to(() => TicketDetailScreen(ticket: ticket));
              _loadTickets(); // Refresh lại danh sách
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header thẻ: tên nhà xe + trạng thái ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Số hiệu xe + tên hãng
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thịnh Phát Bus',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Xe số: ${ticket.busNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // --- Tuyến đường ---
                  Row(
                    children: [
                      const Icon(
                        Icons.route,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${ticket.departure} → ${ticket.destination}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // --- Ngày giờ ---
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Giờ xuất bến: ${ticket.departureTime}${ticket.departureDate.isNotEmpty ? ' ngày ${ticket.departureDate}' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  // --- Footer: mã vé + giá ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ghế: ${ticket.seats.join(', ')}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
