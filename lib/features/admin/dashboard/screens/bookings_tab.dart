import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/ticket_model.dart';
import '../controllers/admin_controller.dart';

/// Tab "Đơn đặt vé" — Admin xem và cập nhật trạng thái vé từ Firestore.
/// Dùng StatefulWidget để lưu tham chiếu controller 1 lần — tránh lỗi
/// lifecycle khi widget nằm trong static const List (AdminDashboardScreen).
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // Lấy controller 1 lần khi widget được mount
  late final AdminController _ctrl;

  // Nhãn cho từng trạng thái vé
  static const _statusLabels = <String?, String>{
    null: 'Tất cả',
    'booked': 'Đang chờ',
    'cancelled': 'Đã huỷ',
    'completed': 'Hoàn thành',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── FILTER CHIPS ────────────────────────────────────────────────
        _buildFilterBar(),

        // ── DANH SÁCH VÉ ────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (_ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = _ctrl.filteredTickets;

            if (tickets.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _ctrl.loadAll,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: tickets.length,
                itemBuilder: (_, index) =>
                    _TicketCard(ticket: tickets[index], ctrl: _ctrl),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── FILTER BAR ──────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final filters = _statusLabels.keys.toList(); // [null, 'booked', ...]
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: SizedBox(
        height: 36,
        child: Obx(() {
          final current = _ctrl.ticketStatusFilter.value;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final f = filters[index];
              final selected = current == f;
              return ChoiceChip(
                label: Text(_statusLabels[f] ?? 'Tất cả'),
                selected: selected,
                onSelected: (_) => _ctrl.ticketStatusFilter.value = f,
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
                    color: selected
                        ? AppColors.adminPrimary
                        : Colors.grey.shade300,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltering = _ctrl.ticketStatusFilter.value != null;
    final filterLabel =
        _statusLabels[_ctrl.ticketStatusFilter.value] ?? 'Tất cả';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            isFiltering
                ? 'Không có đơn vé "$filterLabel"'
                : 'Chưa có đơn đặt vé nào',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Thẻ vé xe — nhận controller qua constructor để tránh Get.find trong build()
// ════════════════════════════════════════════════════════════════════════════
class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final AdminController ctrl;

  const _TicketCard({required this.ticket, required this.ctrl});

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
            // ── Hàng 1: Mã vé + Badge trạng thái ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${_shortId(ticket.id)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                _statusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Hàng 2: Tuyến đường ─────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.directions_bus_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${ticket.departure} → ${ticket.destination}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Hàng 3: Số xe + giờ ─────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  ticket.busNumber,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${ticket.departureTime} — ${ticket.departureDate}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Hàng 4: User ID rút gọn ─────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'UID: ${_shortId(ticket.userId)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Hàng 5: Ghế + giá + nút hành động ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket.seats.length} ghế: ${ticket.seats.join(', ')}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      '${_formatPrice(ticket.totalPrice)}đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.adminPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                _buildActions(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Rút gọn ID an toàn (tránh RangeError nếu ID ngắn) ───────────────────

  String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 12)}...';
  }

  // ── Nút hành động ────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    if (ticket.status == 'booked') {
      return Row(
        children: [
          TextButton(
            onPressed: () => _confirmCancel(),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Huỷ vé'),
          ),
          ElevatedButton(
            onPressed: () => ctrl.updateTicketStatus(ticket.id, 'completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(0, 34),
            ),
            child: const Text('Hoàn thành', style: TextStyle(fontSize: 12.5)),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmCancel() {
    Get.defaultDialog(
      title: 'Huỷ vé?',
      middleText:
          'Huỷ vé #${_shortId(ticket.id)} sẽ hoàn trả ghế cho chuyến xe.',
      textConfirm: 'Xác nhận huỷ',
      textCancel: 'Bỏ qua',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        ctrl.updateTicketStatus(ticket.id, 'cancelled');
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _statusBadge(String status) {
    final Color color;
    final String label;
    switch (status) {
      case 'booked':
        color = Colors.orange;
        label = 'Đang chờ';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Đã huỷ';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'Hoàn thành';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
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
