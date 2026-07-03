import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Giả lập đăng nhập thành công vào vai Khách hàng
                Get.offAllNamed(AppRoutes.customerHome);
              },
              child: const Text('Đăng nhập Khách hàng'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Giả lập đăng nhập thành công vào vai Admin
                Get.offAllNamed(AppRoutes.adminDashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Đăng nhập Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
