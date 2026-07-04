import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/trip_model.dart';
import 'trip_form_screen.dart';

/// Tab "Chuyến xe" — Quản trị viên xem, thêm, sửa, xoá các chuyến xe.
class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  @override
  Widget build(BuildContext context) {
    final trips = MockData.trips;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm chuyến'),
        onPressed: () => _openForm(),
      ),
      body: trips.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: trips.length,
              itemBuilder: (context, index) =>
                  _AdminTripCard(
                trip: trips[index],
                onEdit: () => _openForm(trip: trips[index]),
                onDelete: () => _confirmDelete(trips[index]),
              ),
            ),
    );
  }

  Future<void> _openForm({TripModel? trip}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TripFormScreen(trip: trip)),
    );
    if (result == true) setState(() {});
  }

  void _confirmDelete(TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá chuyến xe?'),
        content: Text(
            'Bạn có chắc muốn xoá chuyến ${trip.busNumber} (${trip.departure} → ${trip.destination})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              setState(() => MockData.trips.remove(trip));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xoá chuyến xe'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xoá', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_filled,
              size: 72, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Chưa có chuyến xe nào',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Thẻ chuyến xe (dạng quản trị) — có nút Sửa / Xoá
// ════════════════════════════════════════════════════════════
class _AdminTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminTripCard({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
  });

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
            // ── Hàng 1: Số xe + loại xe + menu ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.adminPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.busNumber,
                    style: const TextStyle(
                        color: AppColors.adminPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.busType,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Xoá', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Hàng 2: Tuyến đường + giờ ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.departureTime}  ${trip.departure}',
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(Icons.arrow_downward,
                              size: 12, color: AppColors.textSecondary),
                        ],
                      ),
                      Text('${trip.arrivalTime}  ${trip.destination}',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  '${_formatPrice(trip.price)}đ',
                  style: const TextStyle(
                    color: AppColors.adminPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Hàng 3: Ghế trống / tổng ghế ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_seat,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.availableSeats}/${trip.totalSeats} ghế trống',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  width: 120,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: trip.totalSeats == 0
                        ? 0
                        : trip.bookedSeats / trip.totalSeats,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.adminPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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