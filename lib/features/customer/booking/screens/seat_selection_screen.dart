import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/ticket_service.dart';
import 'booking_confirmation_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TripModel trip;
  final String departureDate;

  const SeatSelectionScreen({
    super.key,
    required this.trip,
    required this.departureDate,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  List<String> _bookedSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookedSeats();
  }

  Future<void> _fetchBookedSeats() async {
    final seats = await Get.find<TicketService>().getBookedSeats(
      widget.trip.id,
      widget.departureDate,
    );
    if (mounted) {
      setState(() {
        _bookedSeats = seats;
        _isLoading = false;
      });
    }
  }

  // Tạo danh sách mã ghế ảo dựa trên tổng số ghế
  List<String> _generateSeatList() {
    List<String> seats = [];
    final prefix = ['A', 'B'];

    // Đơn giản hóa: Cứ rải từ A1, A2... B1, B2...
    int count = 1;
    for (int i = 1; i <= widget.trip.totalSeats; i++) {
      String prefixChar = prefix[(count - 1) % prefix.length];
      int rowNumber = ((count - 1) ~/ prefix.length) + 1;
      seats.add('$prefixChar$rowNumber');
      count++;
    }
    return seats;
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeats.contains(seatId)) return; // Ghế đã đặt

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length >= 6) {
          Get.snackbar('Thông báo', 'Chỉ được chọn tối đa 6 ghế 1 lần');
          return;
        }
        _selectedSeats.add(seatId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seats = _generateSeatList();
    final totalPrice = _selectedSeats.length * widget.trip.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ghế'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // Ghi chú màu sắc
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(Colors.white, 'Trống', border: true),
                      _buildLegendItem(Colors.grey.shade400, 'Đã đặt'),
                      _buildLegendItem(AppColors.primary, 'Đang chọn'),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Sơ đồ ghế
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 ghế 1 hàng
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: widget.trip.totalSeats,
                    itemBuilder: (context, index) {
                      final seatId = seats[index];
                      final isBooked = _bookedSeats.contains(seatId);
                      final isSelected = _selectedSeats.contains(seatId);

                      return GestureDetector(
                        onTap: () => _toggleSeat(seatId),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.grey.shade300
                                : (isSelected
                                      ? AppColors.primary
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.grey.shade400
                                  : (isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade300),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            seatId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBooked
                                  ? Colors.grey.shade600
                                  : (isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedSeats.length} ghế đang chọn',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _selectedSeats.isEmpty
                    ? null
                    : () {
                        Get.to(
                          () => BookingConfirmationScreen(
                            trip: widget.trip,
                            selectedSeats: _selectedSeats,
                            totalPrice: totalPrice,
                            departureDate: widget.departureDate,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: Colors.grey.shade400) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
