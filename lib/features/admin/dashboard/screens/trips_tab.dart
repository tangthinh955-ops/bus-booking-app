import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/trip_model.dart';
import '../controllers/admin_controller.dart';
import 'trip_form_screen.dart';

/// Tab "Chuyến xe" — Admin xem, thêm, sửa, xoá các chuyến xe.
/// Dữ liệu lấy từ [AdminController] (Firestore thật), không dùng MockData.
class TripsTab extends GetView<AdminController> {
  const TripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm chuyến'),
        onPressed: () => _openForm(context),
      ),
      body: Column(
        children: [
          // ── THANH TÌM KIẾM ───────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Tìm theo điểm đi, điểm đến, số xe...',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.adminPrimary,
                  size: 20,
                ),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => controller.searchQuery.value = '',
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── DANH SÁCH CHUYẾN XE ──────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Hiển thị spinner trong lúc đang tải dữ liệu lần đầu
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final trips = controller.filteredTrips;

              if (trips.isEmpty) {
                return _buildEmptyState(
                  isSearching: controller.searchQuery.value.isNotEmpty,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadAll,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return _AdminTripCard(
                      trip: trip,
                      onEdit: () => _openForm(context, trip: trip),
                      onDelete: () => _confirmDelete(context, trip),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Mở màn hình form thêm hoặc sửa chuyến xe.
  void _openForm(BuildContext context, {TripModel? trip}) {
    Get.to(() => TripFormScreen(trip: trip));
  }

  /// Hiển thị dialog xác nhận trước khi xóa chuyến xe.
  void _confirmDelete(BuildContext context, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá chuyến xe?'),
        content: Text(
          'Bạn có chắc muốn xoá chuyến ${trip.busNumber} '
          '(${trip.departure} → ${trip.destination})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi controller — tự xóa Firestore + cập nhật list local
              controller.deleteTrip(trip.id);
            },
            child: const Text('Xoá', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isSearching = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.directions_bus_filled,
            size: 72,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'Không tìm thấy chuyến xe phù hợp'
                : 'Chưa có chuyến xe nào',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (isSearching) ...[
            const SizedBox(height: 6),
            const Text(
              'Thử tìm kiếm từ khóa khác',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.adminPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.busNumber,
                    style: const TextStyle(
                      color: AppColors.adminPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.busType,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
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

            // ── Hàng 2: Tuyến đường + giờ + giá ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.departureTime}  ${trip.departure}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      Text(
                        '${trip.arrivalTime}  ${trip.destination}',
                        style: const TextStyle(fontSize: 13),
                      ),
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

            // ── Hàng 3: Ghế trống / tổng ghế + thanh tiến trình ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.availableSeats}/${trip.totalSeats} ghế trống',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
