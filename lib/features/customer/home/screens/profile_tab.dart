import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';

/// Tab "Tài khoản" - thông tin và cài đặt tài khoản người dùng
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- PHẦN HEADER AVATAR ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            color: AppColors.primary,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'nguyenvana@gmail.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- PHẦN MENU CÀI ĐẶT ---
          const SizedBox(height: 16),
          _buildMenuSection(
            title: 'Tài khoản',
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Thông tin cá nhân',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                label: 'Đổi mật khẩu',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMenuSection(
            title: 'Hỗ trợ',
            items: [
              _MenuItem(
                icon: Icons.help_outline,
                label: 'Trợ giúp & Hỏi đáp',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.phone_outlined,
                label: 'Liên hệ: 1900 6067',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- NÚT ĐĂNG XUẤT ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.login);
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tạo section menu với tiêu đề và danh sách các mục
  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Bọc Material để ListTile hiển thị ripple effect (hiệu ứng nhấn) đúng cách.
        // Nếu không có Material, Flutter sẽ báo lỗi vì không biết vẽ ink splash lên đâu.
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: items.map((item) {
                  final isLast = items.last == item;
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(item.icon, color: AppColors.primary),
                        title: Text(item.label),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary),
                        onTap: item.onTap,
                      ),
                      if (!isLast)
                        const Divider(height: 1, indent: 56, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Model nhỏ cho mỗi dòng menu trong Profile
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}
