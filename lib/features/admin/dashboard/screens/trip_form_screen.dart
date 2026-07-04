import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/trip_model.dart';

/// Màn hình Thêm mới / Chỉnh sửa một chuyến xe.
/// Nếu [trip] == null → chế độ Thêm mới.
/// Nếu [trip] != null → chế độ Sửa (điền sẵn dữ liệu cũ).
class TripFormScreen extends StatefulWidget {
  final TripModel? trip;

  const TripFormScreen({super.key, this.trip});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _busNumberCtrl;
  late final TextEditingController _busTypeCtrl;
  late final TextEditingController _departureTimeCtrl;
  late final TextEditingController _arrivalTimeCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _totalSeatsCtrl;
  late final TextEditingController _availableSeatsCtrl;
  late final TextEditingController _amenitiesCtrl;

  String? _departure;
  String? _destination;
  final List<String> _cities = TripModel.popularCities;

  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _busNumberCtrl = TextEditingController(text: t?.busNumber ?? '');
    _busTypeCtrl = TextEditingController(text: t?.busType ?? '');
    _departureTimeCtrl = TextEditingController(text: t?.departureTime ?? '');
    _arrivalTimeCtrl = TextEditingController(text: t?.arrivalTime ?? '');
    _durationCtrl = TextEditingController(text: t?.duration ?? '');
    _priceCtrl = TextEditingController(text: t?.price.toInt().toString() ?? '');
    _totalSeatsCtrl =
        TextEditingController(text: t?.totalSeats.toString() ?? '');
    _availableSeatsCtrl =
        TextEditingController(text: t?.availableSeats.toString() ?? '');
    _amenitiesCtrl =
        TextEditingController(text: t?.amenities.join(', ') ?? '');
    _departure = t?.departure;
    _destination = t?.destination;
  }

  @override
  void dispose() {
    _busNumberCtrl.dispose();
    _busTypeCtrl.dispose();
    _departureTimeCtrl.dispose();
    _arrivalTimeCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _totalSeatsCtrl.dispose();
    _availableSeatsCtrl.dispose();
    _amenitiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa chuyến xe' : 'Thêm chuyến xe'),
        backgroundColor: AppColors.adminPrimary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Thông tin xe'),
            _textField(_busNumberCtrl, 'Số hiệu xe', Icons.badge,
                hint: 'VD: AP-L01'),
            _textField(_busTypeCtrl, 'Loại xe', Icons.airline_seat_recline_normal,
                hint: 'VD: Limousine 9 chỗ'),

            _sectionTitle('Tuyến đường'),
            Row(
              children: [
                Expanded(
                  child: _cityDropdown(
                    label: 'Điểm đi',
                    value: _departure,
                    onChanged: (v) => setState(() => _departure = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _cityDropdown(
                    label: 'Điểm đến',
                    value: _destination,
                    onChanged: (v) => setState(() => _destination = v),
                  ),
                ),
              ],
            ),

            _sectionTitle('Thời gian'),
            Row(
              children: [
                Expanded(
                  child: _textField(
                      _departureTimeCtrl, 'Giờ đi', Icons.schedule,
                      hint: 'VD: 07:00'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                      _arrivalTimeCtrl, 'Giờ đến', Icons.schedule,
                      hint: 'VD: 13:00'),
                ),
              ],
            ),
            _textField(_durationCtrl, 'Thời lượng', Icons.timelapse,
                hint: 'VD: 6 tiếng'),

            _sectionTitle('Giá & Số ghế'),
            _textField(_priceCtrl, 'Giá vé (VNĐ)', Icons.payments,
                keyboardType: TextInputType.number),
            Row(
              children: [
                Expanded(
                  child: _textField(
                      _totalSeatsCtrl, 'Tổng số ghế', Icons.event_seat,
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(_availableSeatsCtrl, 'Ghế trống',
                      Icons.event_available,
                      keyboardType: TextInputType.number),
                ),
              ],
            ),

            _sectionTitle('Tiện ích'),
            _textField(_amenitiesCtrl, 'Tiện ích (cách nhau bởi dấu phẩy)',
                Icons.star_outline,
                hint: 'VD: WiFi, Điều hoà, Nước uống'),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm chuyến xe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.adminPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.adminPrimary),
          ),
        ),
        validator: (val) =>
            (val == null || val.trim().isEmpty) ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _cityDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        items: _cities
            .map((c) => DropdownMenuItem(
                value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Vui lòng chọn $label' : null,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_departure == _destination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm đi và điểm đến không được trùng nhau'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amenities = _amenitiesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newTrip = TripModel(
      id: widget.trip?.id ?? 'trip_${DateTime.now().millisecondsSinceEpoch}',
      busNumber: _busNumberCtrl.text.trim(),
      busType: _busTypeCtrl.text.trim(),
      departure: _departure!,
      destination: _destination!,
      departureTime: _departureTimeCtrl.text.trim(),
      arrivalTime: _arrivalTimeCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      totalSeats: int.tryParse(_totalSeatsCtrl.text.trim()) ?? 0,
      availableSeats: int.tryParse(_availableSeatsCtrl.text.trim()) ?? 0,
      amenities: amenities,
    );

    if (_isEditing) {
      final index = MockData.trips.indexWhere((t) => t.id == widget.trip!.id);
      if (index != -1) MockData.trips[index] = newTrip;
    } else {
      MockData.trips.add(newTrip);
    }

    Navigator.of(context).pop(true);
  }
}