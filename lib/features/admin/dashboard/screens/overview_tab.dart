import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/ticket_model.dart';
import '../controllers/admin_controller.dart';
import 'package:intl/intl.dart';

/// Tab "Tổng quan" — Trang chủ của khu vực Quản trị viên.
/// Hiển thị các chỉ số nhanh (số chuyến, doanh thu, vé đã bán, đơn chờ xử lý)
/// và danh sách các đơn đặt vé gần đây nhất.
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late final AdminController _adminCtrl;

  @override
  void initState() {
    super.initState();
    _adminCtrl = Get.find<AdminController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recentBookings = _adminCtrl.filteredTickets.take(4).toList();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // ── LƯỚI THỐNG KÊ NHANH ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    icon: Icons.directions_bus,
                    label: 'Tổng chuyến xe',
                    value: '${_adminCtrl.totalTrips}',
                    color: AppColors.adminPrimary,
                  ),
                  _StatCard(
                    icon: Icons.event_seat,
                    label: 'Vé (ghế) đã bán',
                    value: '${_adminCtrl.totalSeatsSold}',
                    color: AppColors.success,
                  ),
                  _StatCard(
                    icon: Icons.pending_actions,
                    label: 'Đơn chờ xử lý',
                    value: '${_adminCtrl.pendingCount}',
                    color: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.payments,
                    label: 'Doanh thu',
                    value: _formatPrice(_adminCtrl.totalRevenue),
                    color: AppColors.adminPrimaryDark,
                    isSmallValue: true,
                  ),
                ],
              ),
            ),

            // ── TIÊU ĐỀ DANH SÁCH ──
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Đơn đặt vé gần đây',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),

            // ── DANH SÁCH ĐƠN GẦN ĐÂY ──
            if (recentBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Chưa có đơn vé nào.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: recentBookings
                      .map((t) => _RecentBookingTile(ticket: t))
                      .toList(),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.adminPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                AppStrings.companyName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Xin chào, Quản trị viên 👋',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$strđ';
  }
}

// ════════════════════════════════════════════════════════════
// Thẻ thống kê nhỏ
// ════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isSmallValue;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isSmallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallValue ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Dòng đơn đặt vé gần đây
// ════════════════════════════════════════════════════════════
class _RecentBookingTile extends StatelessWidget {
  final TicketModel ticket;

  const _RecentBookingTile({required this.ticket});

  String _shortId(String id) {
    if (id.length <= 6) return id;
    return id.substring(id.length - 6).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.adminPrimary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.adminPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khách UID: ${_shortId(ticket.userId)}',
                    style:
                        const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${ticket.departure} → ${ticket.destination}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusBadge(ticket.status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
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
        color = AppColors.primary;
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
            color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}