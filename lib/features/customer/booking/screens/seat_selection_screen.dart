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
  int _currentFloorIndex = 0; // 0: Tầng dưới (B), 1: Tầng trên (A)

  bool get _isSleeper => widget.trip.busType.toLowerCase().contains('giường');

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

  // Tạo danh sách ghế theo prefix
  List<String> _generateSeatListWithPrefix(String prefix, int count) {
    return List.generate(count, (index) => '$prefix${index + 1}');
  }

  // Phân loại ghế theo tầng
  Map<String, List<String>> _generateSeatFloors() {
    if (_isSleeper) {
      // Xe giường nằm (Ví dụ: 34 chỗ -> 17 trên, 17 dưới)
      final int seatsPerFloor = widget.trip.totalSeats ~/ 2;
      List<String> lowerFloor = _generateSeatListWithPrefix('B', seatsPerFloor);
      List<String> upperFloor = _generateSeatListWithPrefix('A', seatsPerFloor);

      // Xử lý ghế lẻ nếu có
      if (widget.trip.totalSeats % 2 != 0) {
        upperFloor.add('A${seatsPerFloor + 1}');
      }

      return {'Tầng dưới': lowerFloor, 'Tầng trên': upperFloor};
    } else {
      // Xe ghế ngồi: 1 sơ đồ chung
      List<String> seats = [];

      if (widget.trip.totalSeats > 20) {
        // Xe ghế ngồi lớn (Ví dụ: 34 chỗ) -> Nửa trên A, Nửa dưới B
        final int halfSeats = widget.trip.totalSeats ~/ 2;
        seats.addAll(_generateSeatListWithPrefix('A', halfSeats));
        seats.addAll(
          _generateSeatListWithPrefix('B', widget.trip.totalSeats - halfSeats),
        );
      } else {
        // Xe nhỏ (Ví dụ: Limousine 9 chỗ) -> Mặc định chỉ dùng prefix A
        seats.addAll(_generateSeatListWithPrefix('A', widget.trip.totalSeats));
      }

      return {'Sơ đồ ghế': seats};
    }
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
    final floors = _generateSeatFloors();
    final floorNames = floors.keys.toList();

    // Đảm bảo index hợp lệ
    if (_currentFloorIndex >= floorNames.length) {
      _currentFloorIndex = 0;
    }

    final currentFloorSeats = floors[floorNames[_currentFloorIndex]]!;
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

                if (_isSleeper) ...[
                  // Nút chuyển tầng
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: List.generate(floorNames.length, (index) {
                          final isSelected = _currentFloorIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _currentFloorIndex = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  floorNames[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                    itemCount: currentFloorSeats.length,
                    itemBuilder: (context, index) {
                      final seatId = currentFloorSeats[index];
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
