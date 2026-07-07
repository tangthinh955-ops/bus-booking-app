import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../services/auth_service.dart';
import 'register_screen.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true; // true = đang ẩn mật khẩu
  final FocusNode _passwordFocusNode =
      FocusNode(); // Để chuyển focus khi nhấn Enter

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose(); // Giải phóng FocusNode khi widget bị xóa
    super.dispose();
  }

  /// Hiển thị hộp thoại nhập email để gửi link đặt lại mật khẩu
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final authService = Get.find<AuthService>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quên mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu đến hộp thư của bạn.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.of(ctx).pop(); // Đóng dialog
              final error = await authService.resetPassword(email);
              if (error == null) {
                Get.snackbar(
                  'Đã gửi email',
                  'Kiểm tra hộp thư của bạn để đặt lại mật khẩu.',
                  backgroundColor: Colors.green.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              } else {
                Get.snackbar(
                  'Lỗi',
                  error,
                  backgroundColor: Colors.red.withValues(alpha: 0.9),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Gửi email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.directions_bus_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thịnh Phát Bus',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đăng nhập để tiếp tục',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 36),

                  // Nhập Email hoặc SĐT
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.text, // Cho phép cả chữ và số
                    // Khi nhấn Enter trên bàn phím → chuyển sang ô mật khẩu
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    decoration: InputDecoration(
                      labelText: 'Email hoặc số điện thoại',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email hoặc số điện thoại';
                      }
                      return null; // Kiểm tra format để Firebase tự xử lý
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nhập Mật khẩu
                  TextFormField(
                    controller: _passwordController,
                    focusNode:
                        _passwordFocusNode, // Nhận focus khi Email nhấn Enter
                    obscureText: _obscurePassword,
                    // Khi nhấn Enter ở ô mật khẩu → submit form luôn
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      if (_formKey.currentState!.validate()) {
                        _authController.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      // Icon con mắt để ẩn/hiện mật khẩu
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                  ),
                  const SizedBox(height: 24),

                  // Nút Đăng nhập
                  Obx(
                    () => ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _authController.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Chuyển sang Đăng ký
                  TextButton(
                    onPressed: () => Get.to(() => const RegisterScreen()),
                    child: const Text(
                      'Chưa có tài khoản? Đăng ký ngay',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
