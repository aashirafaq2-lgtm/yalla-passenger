import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'map_selection_screen.dart';
import 'trip_information_screen.dart';

class ScheduleTripConfigScreen extends StatefulWidget {
  const ScheduleTripConfigScreen({super.key});

  @override
  State<ScheduleTripConfigScreen> createState() => _ScheduleTripConfigScreenState();
}

class _ScheduleTripConfigScreenState extends State<ScheduleTripConfigScreen> {
  int seats = 1;
  bool frontSeat = false;
  String selectedOrigin = 'Kirkuk';
  String selectedDestination = 'Bagdad';
  final List<String> cities = ['Kirkuk', 'Bagdad', 'Erbil', 'Basra', 'Najaf', 'Karbala', 'Mosul'];
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
                          'Schedule a trip',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          const Icon(Icons.arrow_right_alt, size: 30),
                          _buildCityBadge(selectedDestination, (val) => setState(() => selectedDestination = val!)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      // Number of seats
                      _buildActionRow(
                        'Number of seats',
                        Row(
                          children: [
                            _buildCounterButton(Icons.remove, () {
                              if (seats > 1) setState(() => seats--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$seats', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            _buildCounterButton(Icons.add, () {
                              setState(() => seats++);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Front seat
                      _buildActionRow(
                        'Front seat',
                        Checkbox(
                          value: frontSeat,
                          onChanged: (val) => setState(() => frontSeat = val!),
                          activeColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Choose Your location',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Icon(Icons.location_on, color: Colors.black),
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
                                decoration: const InputDecoration(
                                  hintText: 'Discount code',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.black26),
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
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid discount code')));
                              },
                              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text(
                        'Price details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildPriceRow('1x seat', '75,000 IQD'),
                      const SizedBox(height: 12),
                      _buildPriceRow('Front seat', frontSeat ? '5,000 IQD' : 'No'),
                      const Divider(height: 35),
                      _buildPriceRow('Total', '25,250 IQD', isTotal: true),
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TripInformationScreen()));
                    },
                    child: const Text(
                      'Book now',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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

  Widget _buildActionRow(String label, Widget action) {
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
