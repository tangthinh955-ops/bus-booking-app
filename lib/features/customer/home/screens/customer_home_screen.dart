import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_tab.dart';
import 'notifications_tab.dart';
import 'history_tab.dart';
import 'profile_tab.dart';

/// Màn hình chính của Khách hàng.
///
/// Đây là "vỏ bọc" chứa 4 tab bên trong.
/// Khi bấm vào icon ở thanh điều hướng dưới, nó chỉ
/// thay đổi nội dung hiển thị, KHÔNG navigate sang trang mới.
/// Kỹ thuật này gọi là "Bottom Navigation Bar Pattern".
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // Biến theo dõi tab nào đang được chọn (bắt đầu từ 0)
  int _selectedIndex = 0;

  // Danh sách tiêu đề cho AppBar tương ứng với mỗi tab
  static const List<String> _titles = [
    'Đặt vé xe',
    'Thông báo',
    'Lịch sử',
    'Tài khoản',
  ];

  // Danh sách các widget nội dung của mỗi tab.
  // Khai báo ở đây để Flutter không phải tạo lại mỗi khi đổi tab.
  static const List<Widget> _tabs = [
    HomeTab(),
    NotificationsTab(),
    HistoryTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ẩn AppBar khi ở tab Tài khoản vì nó đã có header riêng
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              automaticallyImplyLeading: false, // Ẩn nút "back"
            ),

      // Hiển thị nội dung của tab đang được chọn
      body: _tabs[_selectedIndex],

      // Thanh điều hướng phía dưới
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Cần set fixed khi có >= 4 mục
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          // Khi bấm vào một tab, cập nhật index → Flutter tự rebuild UI
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
