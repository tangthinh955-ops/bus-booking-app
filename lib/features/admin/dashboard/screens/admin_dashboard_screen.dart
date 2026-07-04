import 'package:app_bus/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'overview_tab.dart';
import 'trips_tab.dart';
import 'bookings_tab.dart';
import 'account_tab.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

    @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Tổng quan',
    'Chuyến xe',
    'Đơn đặt vé',
    'Tài khoản',
  ];

  static const List<Widget> _tabs = [
    OverviewTab(),
    TripsTab(),
    BookingsTab(),
    AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Ẩn AppBar ở tab Tổng quan và Tài khoản vì đã có header riêng
      appBar: (_selectedIndex == 0 || _selectedIndex == 3)
          ? null
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
            ),

      body: _tabs[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.adminPrimary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            activeIcon: Icon(Icons.directions_bus),
            label: 'Chuyến xe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn vé',
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
