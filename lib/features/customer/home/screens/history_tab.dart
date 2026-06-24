import 'package:flutter/material.dart';
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
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final bool isCompleted = item['status'] == 'Hoàn thành';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Xe số: ${item['busNumber']}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(
                          color:
                              isCompleted ? AppColors.success : AppColors.error,
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
                    const Icon(Icons.route,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(item['route']!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                // --- Ngày giờ ---
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(item['date']!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(height: 16),
                // --- Footer: mã vé + giá ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã vé: ${item['ticketCode']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      item['price']!,
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
