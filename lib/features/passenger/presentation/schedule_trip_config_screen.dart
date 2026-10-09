import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import 'map_selection_screen.dart';
import 'trip_information_screen.dart';

class ScheduleTripConfigScreen extends StatefulWidget {
  final String? tripId;
  final String initialOrigin;
  final String initialDestination;
  final bool isStaticCity;
  final dynamic pricePerSeat;
  final String driverName;

  const ScheduleTripConfigScreen({
    super.key,
    this.tripId,
    this.initialOrigin = 'Kirkuk',
    this.initialDestination = 'Baghdad',
    this.isStaticCity = true,
    this.pricePerSeat = 15000,
    this.driverName = 'Driver',
  });

  @override
  State<ScheduleTripConfigScreen> createState() => _ScheduleTripConfigScreenState();
}

class _ScheduleTripConfigScreenState extends State<ScheduleTripConfigScreen> {
  int seats = 1;
  bool frontSeat = false;
  late String selectedOrigin;
  late String selectedDestination;
  final List<String> cities = ['Kirkuk', 'Baghdad', 'Erbil', 'Basra', 'Sulaymaniyah', 'Najaf', 'Karbala', 'Mosul', 'Dohuk', 'Anbar', 'Babel', 'Wasit'];
  final TextEditingController _discountCtrl = TextEditingController();
  bool _hasDiscountCode = false;

  @override
  void initState() {
    super.initState();
    selectedOrigin = widget.initialOrigin;
    selectedDestination = widget.initialDestination;
    _discountCtrl.addListener(() {
      setState(() => _hasDiscountCode = _discountCtrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    super.dispose();
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
                          isArabic ? 'تأكيد تفاصيل الرحلة' : 'Schedule a trip',
                          style: TextStyle(
                            fontSize: 18, 
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

              // Form Card
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Route
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCityBadge(selectedOrigin, (val) => setState(() => selectedOrigin = val!)),
                          Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 30),
                          _buildCityBadge(selectedDestination, (val) => setState(() => selectedDestination = val!)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      // Number of seats
                      _buildActionRow(
                        isArabic ? 'عدد المقاعد' : 'Number of seats',
                        Row(
                          children: [
                            _buildCounterButton(Icons.remove, () {
                              if (seats > 1) setState(() => seats--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$seats', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            _buildCounterButton(Icons.add, () {
                              setState(() => seats++);
                            }),
                          ],
                        ),
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      
                      // Front seat
                      _buildActionRow(
                        isArabic ? 'المقعد الأمامي' : 'Front seat',
                        Checkbox(
                          value: frontSeat,
                          onChanged: (val) => setState(() => frontSeat = val!),
                          activeColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      
                      // Location Selector
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MapSelectionScreen()));
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isArabic ? 'حدد موقعك على الخريطة' : 'Choose Your location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600, 
                                  fontSize: 16,
                                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                ),
                              ),
                              const Icon(Icons.location_on, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Discount Code
                      Row(
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
                                  hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
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
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'كود الخصم غير صالح' : 'Invalid discount code')));
                              },
                              child: Text(isArabic ? 'تطبيق' : 'Apply', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Price Details
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'تفاصيل السعر' : 'Price details',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPriceRow(isArabic ? '$seats مقعد' : '${seats}x seat', isArabic ? '${seats * (widget.pricePerSeat ?? 15000)} د.ع' : '${seats * (widget.pricePerSeat ?? 15000)} IQD'),
                      const SizedBox(height: 12),
                      _buildPriceRow(isArabic ? 'المقعد الأمامي' : 'Front seat', frontSeat ? (isArabic ? '5,000 د.ع' : '5,000 IQD') : (isArabic ? 'لا' : 'No')),
                      const Divider(height: 35),
                      _buildPriceRow(isArabic ? 'الإجمالي' : 'Total', isArabic ? '${(seats * (widget.pricePerSeat ?? 15000)) + (frontSeat ? 5000 : 0)} د.ع' : '${(seats * (widget.pricePerSeat ?? 15000)) + (frontSeat ? 5000 : 0)} IQD', isTotal: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Book Now Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripInformationScreen(
                            rideData: {
                              'tripId': widget.tripId,
                              'from': selectedOrigin,
                              'to': selectedDestination,
                              'seats': seats,
                              'frontSeat': frontSeat,
                              'driverName': widget.driverName,
                              'price': '${(seats * (widget.pricePerSeat ?? 15000)) + (frontSeat ? 5000 : 0)}',
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      isArabic ? 'احجز الآن' : 'Book now',
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

  Widget _buildCityBadge(String value, ValueChanged<String?> onChanged) {
    if (widget.isStaticCity) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
          dropdownColor: AppColors.primaryOrange,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: cities.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionRow(String label, Widget action, [bool isArabic = false]) {
     return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 16,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
          action,
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 16 : 14,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: isTotal ? Colors.black : Colors.black54,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 16 : 14,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          color: Colors.black,
        )),
      ],
    );
  }
}
