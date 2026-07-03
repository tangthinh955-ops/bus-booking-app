import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Biến theo dõi trạng thái loading (hiện vòng xoay khi đang gọi API)
  final RxBool isLoading = false.obs;

  // Gọi hàm đăng ký
  Future<void> register(
      String name, String phone, String email, String password) async {
    isLoading.value = true;
    String? error =
        await _authService.registerWithEmail(name, phone, email, password);
    isLoading.value = false;

    if (error == null) {
      Get.snackbar(
        'Thành công',
        'Tạo tài khoản thành công',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      // Đăng ký xong thì tự đăng nhập và chuyển trang
      _redirectUser();
    } else {
      Get.snackbar(
        'Lỗi',
        error,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  // Gọi hàm đăng nhập
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    String? error = await _authService.loginWithEmail(email, password);
    isLoading.value = false;

    if (error == null) {
      _redirectUser();
    } else {
      Get.snackbar(
        'Lỗi',
        error,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  // Chuyển hướng người dùng dựa vào role
  Future<void> _redirectUser() async {
    String role = await _authService.getUserRole();
    if (role == 'admin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.customerHome);
    }
  }
}
