import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/booking_model.dart';

/// Tab "Đơn đặt vé" — Quản trị viên xem và xử lý các đơn đặt vé của khách.
/// Có thể xác nhận (pending → confirmed) hoặc huỷ đơn (→ cancelled).
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  BookingStatus? _filter; // null = tất cả

  @override
  Widget build(BuildContext context) {
    final bookings = MockData.bookings
        .where((b) => _filter == null || b.status == _filter)
        .toList()
        .reversed
        .toList();

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => _BookingCard(
                    booking: bookings[index],
                    onChanged: () => setState(() {}),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = <BookingStatus?>[
      null,
      BookingStatus.pending,
      BookingStatus.confirmed,
      BookingStatus.completed,
      BookingStatus.cancelled,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final f = filters[index];
            final selected = _filter == f;
            return ChoiceChip(
              label: Text(f == null ? 'Tất cả' : f.label),
              selected: selected,
              onSelected: (_) => setState(() => _filter = f),
              selectedColor: AppColors.adminPrimary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? AppColors.adminPrimary : Colors.grey.shade300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Không có đơn đặt vé nào',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Thẻ đơn đặt vé — có nút Xác nhận / Huỷ tuỳ theo trạng thái
// ════════════════════════════════════════════════════════════
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onChanged;

  const _BookingCard({required this.booking, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${booking.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                _statusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(booking.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(width: 10),
                const Icon(Icons.phone_outlined,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(booking.phone,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.directions_bus_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(booking.route,
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(booking.departureTime,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${booking.seatCount} ghế · ${_formatPrice(booking.totalPrice)}đ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.adminPrimary,
                        fontSize: 13.5)),
                _buildActions(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (booking.status == BookingStatus.pending) {
      return Row(
        children: [
          TextButton(
            onPressed: () => _updateStatus(context, BookingStatus.cancelled),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => _updateStatus(context, BookingStatus.confirmed),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _updateStatus(BuildContext context, BookingStatus status) {
    booking.status = status;
    onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == BookingStatus.confirmed
            ? 'Đã xác nhận đơn ${booking.id}'
            : 'Đã huỷ đơn ${booking.id}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _statusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.confirmed:
        color = AppColors.success;
        break;
      case BookingStatus.cancelled:
        color = AppColors.error;
        break;
      case BookingStatus.completed:
        color = AppColors.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
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