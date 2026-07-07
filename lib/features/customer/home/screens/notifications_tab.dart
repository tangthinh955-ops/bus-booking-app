import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/notification_service.dart';

/// Tab "Thông báo" - hiển thị các thông báo từ hệ thống
class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _notificationService = Get.find<NotificationService>();
  final _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem thông báo'));
    }

    return FutureBuilder<List<Map<String, String>>>(
      future: _notificationService.getNotifications(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Đã có lỗi xảy ra'));
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Bạn chưa có thông báo nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  _getIcon(notif['icon'] ?? ''),
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                notif['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notif['body'] ?? '', 
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['time'] ?? '',
                    style: const TextStyle(
                      fontSize: 12, 
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            );
          },
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
      case 'directions_bus':
        return Icons.directions_bus;
      default:
        return Icons.notifications;
    }
  }
}