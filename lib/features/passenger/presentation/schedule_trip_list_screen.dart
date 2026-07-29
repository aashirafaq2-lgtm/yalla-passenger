import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'schedule_trip_config_screen.dart';

class ScheduleTripListScreen extends StatefulWidget {
  const ScheduleTripListScreen({super.key});

  @override
  State<ScheduleTripListScreen> createState() => _ScheduleTripListScreenState();
}

class _ScheduleTripListScreenState extends State<ScheduleTripListScreen> {
  String filterOrigin = 'Kirkuk';
  String filterDest = 'Bagdad';
  final List<String> cities = ['Kirkuk', 'Bagdad', 'Erbil', 'Basra', 'Najaf', 'Karbala', 'Mosul'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Trip List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTripCard(
                    context,
                    from: 'Kirkuk',
                    to: 'Bagdad',
                    time: '2:00 PM',
                    date: '14/2/2026',
                    seats: '4',
                    price: '75,000 IQD',
                    car: 'Dodge Charger',
                    index: 0,
                  ),
                  _buildTripCard(
                    context,
                    from: 'Kirkuk',
                    to: 'Erbil',
                    time: '2:00 PM',
                    date: '14/2/2026',
                    seats: '4',
                    price: '10,000 IQD',
                    car: 'Toyota Corolla',
                    index: 1,
                  ),
                  _buildInteractiveFilterCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    required String from,
    required String to,
    required String time,
    required String date,
    required String seats,
    required String price,
    required String car,
    required int index,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Route
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCityBadge(from),
                const Icon(Icons.arrow_right_alt, size: 30),
                _buildCityBadge(to),
              ],
            ),
            const SizedBox(height: 20),
            // Info Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.accessible_forward, seats, 'Seats'),
                _buildInfoItem(Icons.access_time_filled, time, 'Time'),
                _buildInfoItem(Icons.calendar_month, date, 'Date'),
              ],
            ),
            const SizedBox(height: 20),
            // Sub Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.directions_car, size: 24),
                    Text(car, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Book Button
            SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScheduleTripConfigScreen()),
                  );
                },
                child: const Text('Book now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityBadge(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: AppColors.primaryOrange.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: Text(
        city,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildInteractiveFilterCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterBadge(filterOrigin, (val) => setState(() => filterOrigin = val!)),
                const Icon(Icons.arrow_right_alt, size: 30),
                _buildFilterBadge(filterDest, (val) => setState(() => filterDest = val!)),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryOrange),
                onPressed: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String value, ValueChanged<String?> onChanged) {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: cities.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
