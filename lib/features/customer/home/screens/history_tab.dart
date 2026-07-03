import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../../../core/constants/app_colors.dart';

/// Tab "Lịch sử" - hiển thị các vé đã đặt của người dùng
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  // Dữ liệu giả cho lịch sử vé (tất cả đều của hãng Thịnh Phát Bus)
  static const List<Map<String, String>> _history = [
    {
      'busNumber': 'TP-L01',         // Số hiệu xe Thịnh Phát
      'route': 'HCM → Đà Lạt',
      'date': '20/06/2026 - 07:00',
      'price': '280.000đ',
      'status': 'Hoàn thành',
      'ticketCode': 'TP240620001',
    },
    {
      'busNumber': 'TP-G02',
      'route': 'HCM → Nha Trang',
      'date': '15/06/2026 - 08:00',
      'price': '320.000đ',
      'status': 'Hoàn thành',
      'ticketCode': 'TP240615002',
    },
    {
      'busNumber': 'TP-G03',
      'route': 'HCM → Phan Thiết',
      'date': '10/06/2026 - 06:30',
      'price': '150.000đ',
      'status': 'Đã hủy',
      'ticketCode': 'TP240610003',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
=======
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import 'package:intl/intl.dart';

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
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
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
<<<<<<< HEAD
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final bool isCompleted = item['status'] == 'Hoàn thành';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
=======
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final bool isCompleted = ticket.status == 'completed' || ticket.status == 'booked';
        final displayStatus = ticket.status == 'booked' ? 'Đã đặt' : (ticket.status == 'completed' ? 'Hoàn thành' : 'Đã hủy');

        final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(ticket.bookingDate);
        final formattedPrice = '${ticket.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
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
<<<<<<< HEAD
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Xe số: ${item['busNumber']}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
=======
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
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                          horizontal: 10, vertical: 3),
=======
                        horizontal: 10,
                        vertical: 3,
                      ),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
<<<<<<< HEAD
                        item['status']!,
                        style: TextStyle(
                          color:
                              isCompleted ? AppColors.success : AppColors.error,
=======
                        displayStatus,
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.error,
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // --- Tuyến đường ---
                Row(
                  children: [
<<<<<<< HEAD
                    const Icon(Icons.route,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(item['route']!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
=======
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
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
                  ],
                ),
                const SizedBox(height: 4),
                // --- Ngày giờ ---
                Row(
                  children: [
<<<<<<< HEAD
                    const Icon(Icons.access_time,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(item['date']!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
=======
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ chạy: ${ticket.departureTime} (Mua lúc: $formattedDate)',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
                  ],
                ),
                const Divider(height: 16),
                // --- Footer: mã vé + giá ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
<<<<<<< HEAD
                      'Mã vé: ${item['ticketCode']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      item['price']!,
=======
                      'Ghế: ${ticket.seats.join(', ')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formattedPrice,
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
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
        );
      },
    );
  }
}
