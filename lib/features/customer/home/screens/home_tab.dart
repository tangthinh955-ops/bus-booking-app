import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../services/trip_service.dart';
import '../widgets/trip_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

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
  DateTime _selectedDate = DateTime.now(); // Mặc định là hôm nay

  // Trạng thái bộ lọc và sắp xếp
  String _sortBy = 'time_asc';
  String _filterBusType = 'All';
  List<TripModel> _originalSearchResults = [];

  // Danh sách chuyến đang hiển thị
  List<TripModel> _displayedTrips = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Danh sách thành phố cho dropdown
  final List<String> _cities = TripModel.popularCities;
  final ScrollController _dateScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trạng thái ban đầu: không tìm kiếm, không tải dữ liệu
    _isLoading = false;
    _isSearching = false;
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final now = DateTime.now();
    final difference = _selectedDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference >= 0 &&
        difference < 14 &&
        _dateScrollController.hasClients) {
      // Chiều rộng mỗi item khoảng 78 (70 width + 8 margin)
      final offset =
          (difference * 78.0) - (MediaQuery.of(context).size.width / 2) + 39;
      _dateScrollController.animateTo(
        offset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

      // Lọc chuyến theo ngày được chọn:
      // Nếu chọn hôm nay → chỉ hiện các chuyến giờ > giờ hiện tại
      // Nếu chọn ngày khác → hiện tất cả chuyến (lịch xe hàng ngày)
      final now = DateTime.now();
      final isToday =
          _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      final filtered = isToday
          ? trips.where((trip) {
              final parts = trip.departureTime.split(':');
              final tripHour = int.tryParse(parts[0]) ?? 0;
              final tripMin =
                  int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              final tripMinutes = tripHour * 60 + tripMin;
              final nowMinutes = now.hour * 60 + now.minute;
              return tripMinutes > nowMinutes; // Chỉ lấy chuyến chưa chạy
            }).toList()
          : trips; // Ngày khác → hiện tất cả

      _originalSearchResults = filtered;
      _applyFilterAndSort();
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
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

  /// Mở DatePicker để chọn ngày đi
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
      lastDate: DateTime.now().add(
        const Duration(days: 60),
      ), // Tối đa 60 ngày tới
      locale: const Locale('vi', 'VN'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      // Cập nhật lại kết quả nếu đang ở chế độ tìm kiếm
      if (_isSearching) _searchTrips();
    }
  }

  /// Áp dụng bộ lọc và sắp xếp
  void _applyFilterAndSort() {
    List<TripModel> result = List.from(_originalSearchResults);

    // 1. Lọc theo loại xe
    if (_filterBusType != 'All') {
      result = result.where((t) => t.busType.contains(_filterBusType)).toList();
    }

    // 2. Sắp xếp
    if (_sortBy == 'price_asc') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else {
      // time_asc
      result.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    setState(() {
      _displayedTrips = result;
    });
  }

  /// Mở BottomSheet Lọc & Sắp xếp
  void _showFilterBottomSheet() {
    String tempSort = _sortBy;
    String tempFilter = _filterBusType;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lọc & Sắp xếp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Sắp xếp theo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChoiceChip(
                          'Giờ đi sớm nhất',
                          'time_asc',
                          tempSort,
                          (v) => setModalState(() => tempSort = v),
                        ),
                        _buildChoiceChip(
                          'Giá tăng dần',
                          'price_asc',
                          tempSort,
                          (v) => setModalState(() => tempSort = v),
                        ),
                        _buildChoiceChip(
                          'Giá giảm dần',
                          'price_desc',
                          tempSort,
                          (v) => setModalState(() => tempSort = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Loại xe',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChoiceChip(
                          'Tất cả',
                          'All',
                          tempFilter,
                          (v) => setModalState(() => tempFilter = v),
                        ),
                        _buildChoiceChip(
                          'Limousine',
                          'Limousine',
                          tempFilter,
                          (v) => setModalState(() => tempFilter = v),
                        ),
                        _buildChoiceChip(
                          'Giường nằm',
                          'Giường nằm',
                          tempFilter,
                          (v) => setModalState(() => tempFilter = v),
                        ),
                        _buildChoiceChip(
                          'Ghế ngồi',
                          'Ghế ngồi',
                          tempFilter,
                          (v) => setModalState(() => tempFilter = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sortBy = tempSort;
                            _filterBusType = tempFilter;
                          });
                          _applyFilterAndSort();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChoiceChip(
    String label,
    String value,
    String groupValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
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
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kết quả tìm kiếm (${_displayedTrips.length})',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: const Icon(Icons.tune, color: AppColors.primary),
                        tooltip: 'Lọc & Sắp xếp',
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDeparture = null;
                            _selectedDestination = null;
                            _isSearching = false;
                            _displayedTrips = [];
                          });
                        },
                        child: const Text('Xóa tìm kiếm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ── PHẦN 2.5: THANH CHỌN NGÀY NHANH ──
          if (_isSearching) _buildDateNavigationBar(),

          // ── PHẦN 3: DANH SÁCH CHUYẾN XE ──
          if (!_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bus_alert,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Hãy nhập điểm đi và điểm đến\nđể tìm chuyến xe phù hợp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_isLoading)
            _buildShimmerLoading()
          else if (_displayedTrips.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _displayedTrips.length,
              itemBuilder: (context, index) => TripCard(
                trip: _displayedTrips[index],
                departureDate: DateFormat('dd/MM/yyyy').format(_selectedDate),
              ),
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
                        onTap: () => _showLocationPicker(true),
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
                        onTap: () => _showLocationPicker(false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── HÀNG 2: Ngày đi ──
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày khởi hành',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getSelectedDateString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? "Chọn ${label.toLowerCase()}",
                    style: TextStyle(
                      fontSize: 13,
                      color: value == null
                          ? Colors.grey.shade600
                          : AppColors.textPrimary,
                      fontWeight: value == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mở BottomSheet tìm kiếm Tỉnh/Thành phố
  void _showLocationPicker(bool isDeparture) {
    String searchQuery = '';
    List<String> filteredCities = List.from(_cities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isDeparture ? 'Chọn điểm đi' : 'Chọn điểm đến',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tỉnh/thành phố...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        searchQuery = value;
                        filteredCities = _cities
                            .where(
                              (city) => city.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        return ListTile(
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: isDeparture
                                ? AppColors.primary
                                : AppColors.error,
                          ),
                          title: Text(city),
                          onTap: () {
                            setState(() {
                              if (isDeparture) {
                                _selectedDeparture = city;
                              } else {
                                _selectedDestination = city;
                              }
                            });
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Thanh chọn ngày nhanh
  Widget _buildDateNavigationBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14, // Hiển thị 14 ngày tới
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _searchTrips();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0
                        ? 'Hôm nay'
                        : 'T${date.weekday + 1 == 8 ? 'CN' : date.weekday + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Trạng thái loading giả (Shimmer Skeleton)
  Widget _buildShimmerLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 20, color: Colors.white),
                    Container(width: 60, height: 20, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 50, height: 24, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 40, height: 2, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 50, height: 24, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
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

  /// Lấy chuỗi ngày được chọn dạng "Thứ X, DD/MM/YYYY"
  String _getSelectedDateString() {
    final date = _selectedDate;
    const days = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
    ];
    return '${days[date.weekday % 7]}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
