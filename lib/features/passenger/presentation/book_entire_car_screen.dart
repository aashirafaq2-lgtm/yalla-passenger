import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'map_selection_screen.dart';
import 'book_entire_car_success_screen.dart';

class BookEntireCarScreen extends StatefulWidget {
  const BookEntireCarScreen({super.key});

  @override
  State<BookEntireCarScreen> createState() => _BookEntireCarScreenState();
}

class _BookEntireCarScreenState extends State<BookEntireCarScreen> {
  bool isInternational = false;
  String selectedOrigin = 'Kirkuk';
  String selectedDestination = 'Bagdad';
  String selectedCountryOrigin = 'IRAQ';
  String selectedCountryDest = 'QATAR';
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

  final List<String> cities = ['Kirkuk', 'Bagdad', 'Erbil', 'Basra', 'Najaf', 'Karbala', 'Mosul'];
  final List<String> countries = ['IRAQ', 'QATAR', 'UAE', 'SAUDI ARABIA', 'JORDAN'];
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Book the entire car',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                      Expanded(child: _buildDateTimeCard('Choose date', selectedDate, () => _selectDate(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDateTimeCard('Choose time', selectedTime, () => _selectTime(context))),
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
                      if (!isInternational) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCityBadge(selectedOrigin, cities, (val) => setState(() => selectedOrigin = val!)),
                            const Icon(Icons.arrow_right_alt, size: 30),
                            _buildCityBadge(selectedDestination, cities, (val) => setState(() => selectedDestination = val!)),
                          ],
                        ),
                      ] else ...[
                         _buildCountryFlow(),
                      ],
                      const SizedBox(height: 15),
                      // Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(Icons.accessible_forward, '4', 'Seats'),
                          _buildInfoItem(Icons.access_time, selectedTime, 'Time'),
                          _buildInfoItem(Icons.calendar_month, selectedDate, 'Date'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Price and Car
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem('Price', isInternational ? '100 USD' : '75,000 IQD'),
                          _buildDetailItem('Car', isInternational ? 'Ford' : 'Dodge Charger', isRight: true, icon: Icons.directions_car),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Location Buttons
                      Row(
                        children: [
                          Expanded(child: _buildSmallActionButton('Choose starting point', () => _openMap())),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSmallActionButton('Choose destination', () => _openMap())),
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
                        child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          controller: _discountCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Discount code',
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid discount code')));
                        },
                        child: const Text('Apply'),
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
                    onPressed: () {
                      if (!isInternational) {
                        setState(() => isInternational = true);
                      } else {
                        _showSuccess();
                      }
                    },
                    child: Text(
                      isInternational ? 'Submit' : 'Next',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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

  void _showSuccess() {
    // Navigate to success screen (reusing ScheduleSuccessScreen logic for now or creating a new one)
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookEntireCarSuccessScreen()));
  }

  Widget _buildDateTimeCard(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCityBadge(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
          dropdownColor: AppColors.primaryOrange,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCountryFlow() {
    return Column(
      children: [
        _buildCityBadge(selectedCountryOrigin, countries, (val) => setState(() => selectedCountryOrigin = val!)),
        const Icon(Icons.arrow_downward, size: 30),
        _buildCityBadge(selectedCountryDest, countries, (val) => setState(() => selectedCountryDest = val!)),
      ],
    );
  }

  Widget _buildSmallActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isRight = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (icon != null) Icon(icon, size: 22, color: Colors.black),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
