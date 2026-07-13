import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/ticket_service.dart';
import '../../booking/screens/seat_selection_screen.dart';

// ════════════════════════════════════════════════════════════
// Widget thẻ chuyến xe — Phong cách hãng xe riêng
// ════════════════════════════════════════════════════════════
class TripCard extends StatefulWidget {
  final TripModel trip;
  final String departureDate;

  const TripCard({super.key, required this.trip, required this.departureDate});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  int _availableSeats = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeats();
  }

  Future<void> _fetchSeats() async {
    final bookedSeats = await Get.find<TicketService>().getBookedSeats(
      widget.trip.id,
      widget.departureDate,
    );
    if (mounted) {
      setState(() {
        _availableSeats = widget.trip.totalSeats - bookedSeats.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: (_availableSeats > 0 && !_isLoading)
            ? () {
                Get.to(() => SeatSelectionScreen(
                      trip: widget.trip,
                      departureDate: widget.departureDate,
                    ));
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ── HÀNG 1: Giờ đi → Giờ đến + Giá ──
              Row(
                children: [
                  // Thời gian
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.departureTime,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.trip.departure,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Mũi tên + thời lượng
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.trip.duration,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.textSecondary),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Đến
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.trip.arrivalTime,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.trip.destination,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── HÀNG 2: Loại xe + Tiện ích + Giá + Badge chỗ ──
              Row(
                children: [
                  // Loại xe
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Loại xe
                        Row(
                          children: [
                            const Icon(
                              Icons.airline_seat_recline_normal,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.trip.busType,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Tiện ích
                        Wrap(
                          spacing: 4,
                          children: widget.trip.amenities.take(3).map((a) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Giá + Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatPrice(widget.trip.price)}đ',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSeatBadge(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatBadge() {
    if (_isLoading) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_availableSeats <= 0) {
      return _badge('Hết chỗ', AppColors.error);
    } else if (_availableSeats <= 5) {
      return _badge('Còn $_availableSeats chỗ', Colors.orange);
    } else {
      return _badge('Còn $_availableSeats chỗ', AppColors.success);
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
