import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/ticket_model.dart';

/// Màn hình Chi tiết vé — hiển thị đầy đủ thông tin 1 vé xe khách
class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(ticket.bookingDate);
    final formattedPrice =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
            .format(ticket.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- THẺ VÉ CHÍNH ---
            _buildTicketCard(formattedDate, formattedPrice),
            const SizedBox(height: 16),
            // --- QR CODE ---
            _buildQrSection(),
            const SizedBox(height: 16),
            // --- HỖ TRỢ ---
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(String formattedDate, String formattedPrice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header màu xanh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thịnh Phát Bus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Xe số: ${ticket.busNumber}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Badge trạng thái
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status == 'booked' ? '✓ Đã đặt' : ticket.status,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung: lộ trình
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Điểm đi - Điểm đến
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Điểm đi',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            ticket.departure,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(ticket.departureTime,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_forward,
                            color: AppColors.primary),
                        Text(ticket.duration,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Điểm đến',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          Text(
                            ticket.destination,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(ticket.arrivalTime,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24, color: Color(0xFFEEEEEE)),

                // Thông tin chi tiết
                _buildInfoRow(Icons.chair_outlined, 'Ghế ngồi',
                    ticket.seats.join(', ')),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today_outlined, 'Ngày mua',
                    formattedDate),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.confirmation_number_outlined, 'Mã vé',
                    ticket.id.substring(0, 12).toUpperCase()),

                const Divider(height: 24, color: Color(0xFFEEEEEE)),

                // Tổng tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng tiền',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Mã QR — Xuất trình khi lên xe',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhân viên sẽ quét mã này để xác nhận vé của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          QrImageView(
            // Mã QR chứa: mã vé | tuyến | ghế
            data:
                'TICKET:${ticket.id}|${ticket.departure}-${ticket.destination}|SEATS:${ticket.seats.join(",")}',
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cần hỗ trợ?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, 'Hotline', '1900 6067'),
          const SizedBox(height: 8),
          _buildInfoRow(
              Icons.access_time, 'Giờ làm việc', '6:00 - 22:00 hàng ngày'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Văn phòng',
              '123 Nguyễn Văn Linh, TP.HCM'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
