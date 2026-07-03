import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tab "Thông báo" - hiển thị các thông báo từ hệ thống
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  // Dữ liệu giả cho thông báo
  static const List<Map<String, String>> _notifications = [
    {
      'title': 'Đặt vé thành công!',
<<<<<<< HEAD
      'body': 'Chuyến xe Phương Trang HCM → Đà Lạt lúc 07:00 ngày 25/06/2026 đã được xác nhận.',
=======
      'body':
          'Chuyến xe Phương Trang HCM → Đà Lạt lúc 07:00 ngày 25/06/2026 đã được xác nhận.',
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
      'time': '10 phút trước',
      'icon': 'check_circle',
    },
    {
      'title': 'Khuyến mãi hấp dẫn',
<<<<<<< HEAD
      'body': 'Giảm 20% tất cả chuyến xe đi Đà Lạt cuối tuần này. Đặt ngay kẻo hết!',
=======
      'body':
          'Giảm 20% tất cả chuyến xe đi Đà Lạt cuối tuần này. Đặt ngay kẻo hết!',
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
      'time': '2 giờ trước',
      'icon': 'local_offer',
    },
    {
      'title': 'Nhắc nhở chuyến đi',
<<<<<<< HEAD
      'body': 'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
=======
      'body':
          'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
      'time': 'Hôm qua',
      'icon': 'notifications_active',
    },
    {
      'title': 'Nhắc nhở chuyến đi',
      'body':
          'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
      'time': 'Hôm qua',
      'icon': 'notifications_active',
    },
    {
      'title': 'Nhắc nhở chuyến đi',
      'body':
          'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
      'time': 'Hôm qua',
      'icon': 'notifications_active',
    },
    {
      'title': 'Nhắc nhở chuyến đi',
      'body':
          'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
      'time': 'Hôm qua',
      'icon': 'notifications_active',
    },
    {
      'title': 'Nhắc nhở chuyến đi',
      'body':
          'Chuyến xe của bạn khởi hành sau 2 tiếng nữa. Vui lòng có mặt trước 30 phút.',
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
      'time': 'Hôm qua',
      'icon': 'notifications_active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
<<<<<<< HEAD
      padding: const EdgeInsets.all(16),
=======
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        return ListTile(
<<<<<<< HEAD
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              _getIcon(notif['icon']!),
              color: AppColors.primary,
            ),
=======
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.11),
            child: Icon(_getIcon(notif['icon']!), color: AppColors.primary),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
          ),
          title: Text(
            notif['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notif['body']!, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                notif['time']!,
                style: const TextStyle(
<<<<<<< HEAD
                    fontSize: 12, color: AppColors.textSecondary),
=======
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
>>>>>>> 92683eb5c80672e2aef152ee0d91869305ad7dbe
              ),
            ],
          ),
          isThreeLine: true,
        );
      },
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'local_offer':
        return Icons.local_offer;
      case 'notifications_active':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }
}
