import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final TripModel trip;
  final List<String> selectedSeats;
  final double totalPrice;
  final String departureDate;

  const BookingConfirmationScreen({
    super.key,
    required this.trip,
    required this.selectedSeats,
    required this.totalPrice,
    required this.departureDate,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _authService = Get.find<AuthService>();
  final _ticketService = Get.find<TicketService>();
  bool _isBooking = false;

  void _confirmBooking() async {
    setState(() => _isBooking = true);
    final user = _authService.currentUser;

    final success = await _ticketService.bookTicket(
      trip: widget.trip,
      userId: user!.uid,
      selectedSeats: widget.selectedSeats,
      totalPrice: widget.totalPrice,
      departureDate: widget.departureDate,
    );

    setState(() => _isBooking = false);

    if (success) {
      // Đặt thành công
      Get.snackbar(
        'Thành công', 
        'Bạn đã đặt vé thành công! Vui lòng thanh toán khi lên xe.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Quay về trang chủ (xóa hết stack)
      Get.until((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userName = _authService.userName.value.isNotEmpty 
        ? _authService.userName.value 
        : 'Khách hàng';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt vé'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chuyến đi
            const Text('THÔNG TIN CHUYẾN ĐI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.trip.departure, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Icon(Icons.arrow_right_alt, color: AppColors.primary),
                        Text(widget.trip.destination, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Khởi hành:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(widget.trip.departureTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Loại xe:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(widget.trip.busType, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Thông tin hành khách
            const Text('THÔNG TIN HÀNH KHÁCH', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.email, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(user?.email ?? '', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tóm tắt thanh toán
            const Text('CHI TIẾT THANH TOÁN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ghế đã chọn:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(widget.selectedSeats.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Giá vé (${widget.selectedSeats.length} vé):', style: const TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${widget.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phương thức thanh toán:', style: TextStyle(color: AppColors.textSecondary)),
                        Text('Thanh toán khi lên xe', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isBooking ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isBooking
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                : const Text('THÔNG QUA & ĐẶT VÉ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
