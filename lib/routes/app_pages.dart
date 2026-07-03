import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/customer/home/screens/customer_home_screen.dart';
import '../features/admin/dashboard/screens/admin_dashboard_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeScreen(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
    ),
  ];
}
