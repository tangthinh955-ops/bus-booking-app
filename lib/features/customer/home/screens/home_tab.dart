import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/trip_service.dart';
import '../widgets/trip_card.dart';

/// Tab "Trang chủ" theo phong cách app 1 hãng xe (Futa Bus, Phương Trang...)
/// Gồm 2 phần:
///   1. Form tìm kiếm: Điểm đi → Điểm đến + nút Tìm kiếm
///   2. Danh sách chuyến xe (tất cả hoặc kết quả tìm kiếm)
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Giá trị hiện tại của dropdown Điểm đi / Điểm đến
  String? _selectedDeparture;
  String? _selectedDestination;

  // Danh sách chuyến đang hiển thị
  List<TripModel> _displayedTrips = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Danh sách thành phố cho dropdown
  final List<String> _cities = TripModel.popularCities;

  @override
  void initState() {
    super.initState();
    _loadPopularTrips();
  }

  /// Lấy các chuyến phổ biến (Tất cả chuyến xe mặc định)
  Future<void> _loadPopularTrips() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
    });

    try {
      final trips = await Get.find<TripService>().getAllTrips(); // Hoặc getPopularTrips()
      setState(() {
        _displayedTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu chuyến xe');
    }
  }

  /// Xử lý khi bấm nút "Tìm chuyến xe"
  Future<void> _searchTrips() async {
    if (_selectedDeparture == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đi và điểm đến'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedDeparture == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm đi và điểm đến không được trùng nhau'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final trips = await Get.find<TripService>().searchTrips(
        departure: _selectedDeparture!,
        destination: _selectedDestination!,
      );
      setState(() {
        _displayedTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      print('LỖI TÌM KIẾM: $e');
      setState(() => _isLoading = false);
      Get.snackbar('Lỗi', 'Lỗi khi tìm kiếm: $e');
    }
  }

  /// Hoán đổi điểm đi ↔ điểm đến (tính năng phổ biến trên app xe)
  void _swapLocations() {
    setState(() {
      final temp = _selectedDeparture;
      _selectedDeparture = _selectedDestination;
      _selectedDestination = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PHẦN 1: BANNER + FORM TÌM KIẾM ──
          _buildSearchSection(),

          // ── PHẦN 2: TIÊU ĐỀ DANH SÁCH ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  !_isSearching
                      ? 'Tất cả chuyến xe'
                      : 'Kết quả tìm kiếm (${_displayedTrips.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isSearching)
                  TextButton(
                    onPressed: () {
                      _selectedDeparture = null;
                      _selectedDestination = null;
                      _loadPopularTrips();
                    },
                    child: const Text('Xem tất cả'),
                  ),
              ],
            ),
          ),

          // ── PHẦN 3: DANH SÁCH CHUYẾN XE ──
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_displayedTrips.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _displayedTrips.length,
              itemBuilder: (context, index) =>
                  TripCard(trip: _displayedTrips[index]),
            ),
        ],
      ),
    );
  }

  /// Banner hãng xe + Form tìm kiếm
  Widget _buildSearchSection() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // --- Logo / Tên hãng ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.companyTagline,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // --- Card Form tìm kiếm ---
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── HÀNG 1: Điểm đi ↔ Điểm đến ──
                Row(
                  children: [
                    // Dropdown Điểm đi
                    Expanded(
                      child: _buildLocationDropdown(
                        label: 'Điểm đi',
                        icon: Icons.radio_button_checked,
                        iconColor: AppColors.primary,
                        value: _selectedDeparture,
                        onChanged: (val) =>
                            setState(() => _selectedDeparture = val),
                      ),
                    ),

                    // Nút hoán đổi
                    GestureDetector(
                      onTap: _swapLocations,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),

                    // Dropdown Điểm đến
                    Expanded(
                      child: _buildLocationDropdown(
                        label: 'Điểm đến',
                        icon: Icons.location_on,
                        iconColor: AppColors.error,
                        value: _selectedDestination,
                        onChanged: (val) =>
                            setState(() => _selectedDestination = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── HÀNG 2: Ngày đi (hiển thị ngày hôm nay) ──
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTodayString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '1 hành khách',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── NÚT TÌM CHUYẾN ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _searchTrips,
                    icon: const Icon(Icons.search),
                    label: const Text(
                      AppStrings.searchTrip,
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown chọn điểm đi / điểm đến
  Widget _buildLocationDropdown({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            "Chọn ${label.toLowerCase()}",
            style: const TextStyle(fontSize: 13),
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          items: _cities
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Text(
                    city,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Trạng thái khi không có kết quả tìm kiếm
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Không tìm thấy chuyến xe\nphù hợp với lộ trình này',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy chuỗi ngày hôm nay dạng "Thứ X, DD/MM/YYYY"
  String _getTodayString() {
    final now = DateTime.now();
    const days = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
    ];
    return '${days[now.weekday % 7]}, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}

