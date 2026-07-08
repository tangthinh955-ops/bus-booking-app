import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/customer/home/screens/customer_home_screen.dart';
import '../features/customer/home/screens/profile_edit_screen.dart';
import '../features/customer/home/screens/change_password_screen.dart';
import '../features/admin/dashboard/screens/admin_dashboard_screen.dart';
import '../features/admin/dashboard/controllers/admin_controller.dart';

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
      // Binding: GetX sẽ tự khởi tạo AdminController khi vào trang Admin
      // và tự dispose khi rời khỏi — không cần quản lý thủ công.
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminController>(() => AdminController());
      }),
    ),
    GetPage(
      name: AppRoutes.profileEdit,
      page: () => const ProfileEditScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
    ),
  ];
}
