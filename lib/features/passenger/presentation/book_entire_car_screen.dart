import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import 'map_selection_screen.dart';
import 'book_entire_car_success_screen.dart';

import '../../../core/providers/locale_provider.dart';

class BookEntireCarScreen extends StatefulWidget {
  const BookEntireCarScreen({super.key});

  @override
  State<BookEntireCarScreen> createState() => _BookEntireCarScreenState();
}

class _BookEntireCarScreenState extends State<BookEntireCarScreen> {
  String selectedOrigin = 'Kirkuk';
  String selectedDestination = 'Baghdad';
  String selectedCarType = 'Dodge Charger';
  String selectedDate = '14/2/2026';
  String selectedTime = '2:00 PM';
  final TextEditingController _discountCtrl = TextEditingController();
  bool _hasDiscountCode = false;

  @override
  void initState() {
    super.initState();
    _discountCtrl.addListener(() {
      setState(() => _hasDiscountCode = _discountCtrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    super.dispose();
  }

  final List<String> cities = [
    'Kirkuk',
    'Baghdad',
    'Erbil',
    'Basra',
    'Najaf',
    'Karbala',
    'Mosul',
    'Sulaymaniyah',
    'Duhok',
    'Nasiriyah',
    'Amarah',
    'Samawah',
    'Hillah',
    'Kut',
    'Diwaniyah',
    'Ramadi',
    'Baqubah'
  ];
  final List<String> carTypes = ['Dodge Charger', 'Toyota Camry', 'Hyundai Sonata', 'Ford Taurus'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              FadeInDown(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          isArabic ? 'حجز سيارة كاملة' : 'Book the entire car',
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Date & Time
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildDateTimeCard(isArabic ? 'اختر التاريخ' : 'Choose date', selectedDate, () => _selectDate(context), isArabic)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDateTimeCard(isArabic ? 'اختر الوقت' : 'Choose time', selectedTime, () => _selectTime(context), isArabic)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Booking Details Container
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCityBadge(selectedOrigin, cities, (val) => setState(() => selectedOrigin = val!)),
                          Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 30),
                          _buildCityBadge(selectedDestination, cities, (val) => setState(() => selectedDestination = val!)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(Icons.accessible_forward, '4', isArabic ? 'مقاعد' : 'Seats'),
                          _buildInfoItem(Icons.access_time, selectedTime, isArabic ? 'الوقت' : 'Time'),
                          _buildInfoItem(Icons.calendar_month, selectedDate, isArabic ? 'التاريخ' : 'Date'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Price and Car
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(isArabic ? 'السعر' : 'Price', isArabic ? '75,000 د.ع' : '75,000 IQD'),
                          _buildDetailItem(isArabic ? 'السيارة' : 'Car', selectedCarType, isRight: true, icon: Icons.directions_car),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Location Buttons
                      Row(
                        children: [
                          Expanded(child: _buildSmallActionButton(isArabic ? 'نقطة الانطلاق' : 'Choose starting point', () => _openMap(), isArabic)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSmallActionButton(isArabic ? 'نقطة الوصول' : 'Choose destination', () => _openMap(), isArabic)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Car Type Dropdown
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildDropdown(selectedCarType, carTypes, (val) => setState(() => selectedCarType = val!)),
              ),
              const SizedBox(height: 20),

              // Discount Code
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          controller: _discountCtrl,
                          decoration: InputDecoration(
                            hintText: isArabic ? 'كود الخصم' : 'Discount code',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasDiscountCode
                              ? AppColors.primaryDark
                              : AppColors.primaryOrange.withOpacity(0.7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'كود الخصم غير صالح' : 'Invalid discount code')));
                        },
                        child: Text(isArabic ? 'تطبيق' : 'Apply'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => _submitBooking(),
                    child: _isSubmitting
                        ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryOrange)))
                        : Text(
                            isArabic ? 'إرسال' : 'Submit',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.w900,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MapSelectionScreen()));
  }

  bool _isSubmitting = false;

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final api = Provider.of<ApiService>(context, listen: false);
      final token = await storage.getToken();

      final res = await api.dio.post(
        '/bookings/create',
        data: {
          'type': 'PRIVATE_CAR',
          'pickupName': selectedOrigin,
          'dropName': selectedDestination,
          'totalPrice': 75000,
          'carType': selectedCarType,
          'date': selectedDate,
          'time': selectedTime,
        },
        options: token != null && token.isNotEmpty ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (res.statusCode == 200 || res.statusCode == 201) {
          _showSuccess();
        } else {
          final msg = res.data?['error'] ?? (isArabic ? 'حدث خطأ أثناء إتمام الحجز' : 'Failed to create booking');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
        }
      }
    } catch (e) {
      debugPrint('Book entire car dispatch note: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تعذر إرسال الحجز، يرجى التحقق من الاتصال والمحاولة ثانية' : 'Could not complete booking, please try again.',
            ),
          ),
        );
      }
    }
  }

  void _showSuccess() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookEntireCarSuccessScreen()));
  }

  Widget _buildDateTimeCard(String label, String value, VoidCallback onTap, [bool isArabic = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Text(
              label, 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                fontFamily: isArabic ? 'NotoKufiArabic' : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCityBadge(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          dropdownColor: AppColors.primaryOrange,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16, color: Colors.white)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSmallActionButton(String label, VoidCallback onTap, [bool isArabic = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.bold,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isRight = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 2),
        ],
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
