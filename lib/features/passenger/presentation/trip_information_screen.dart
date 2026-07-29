import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'active_ride_screen.dart';

class TripInformationScreen extends StatelessWidget {
  final dynamic rideData;
  const TripInformationScreen({super.key, this.rideData});

  @override
  Widget build(BuildContext context) {
    final String driverName = rideData?['driverName'] ?? 'Assigned Driver';
    final String carModel   = rideData?['carModel']   ?? '--';
    final String plate      = rideData?['plate']      ?? '---';
    final String from       = rideData?['from']       ?? 'Pickup';
    final String to         = rideData?['to']         ?? 'Drop-off';
    final String price      = rideData?['price'] != null
        ? '${rideData!['price']} IQD' : '75,000 IQD';
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
                          'Trip Information',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Main Trip Card — Figure 2 layout
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Route badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCityBadge(from),
                          const Icon(Icons.arrow_right_alt, size: 30),
                          _buildCityBadge(to),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Info row — seats | time | date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(Icons.accessible_forward, '4', 'Seats'),
                          _buildInfoItem(Icons.access_time, '2:00 PM', 'Time'),
                          _buildInfoItem(Icons.calendar_month_outlined, '14/2/2026', 'Date'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Price and Car model
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(Icons.directions_car, size: 28, color: Colors.black54),
                              Text(carModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // License Plate & Driver row — Figure 2 detail
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54)),
                              Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          // Iraqi License Plate visual widget
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: const Text('IRAQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                                const SizedBox(width: 10),
                                Text(plate == '---' ? '١٢٣٤٥' : plate, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Two orange action buttons — Figure 2
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {},
                              child: const Text('Choose starting point',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {},
                              child: const Text('Choose destination',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Details Section
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('1x seat', '75,000 IQD'),
                          const SizedBox(height: 12),
                          _buildPriceRow('Front seat', 'No'),
                          const SizedBox(height: 12),
                          _buildPriceRow('Discount', '5,000'),
                          const Divider(height: 30),
                          _buildPriceRow('Total', '70,0000 IQD', isTotal: true), // Kept "70,0000" as per design typo
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 8,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ActiveRideScreen(rideData: rideData),
                          ));
                        },
                        child: const Text('Confirm your reservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCCB3),
                          foregroundColor: const Color(0xFFE64A19),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel the ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityBadge(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        if (icon != null) Icon(icon, size: 24, color: Colors.black),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(
          value,
          textAlign: isRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 20 : 17,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: isTotal ? Colors.black : Colors.black54,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 20 : 17,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          color: Colors.black,
        )),
      ],
    );
  }
}
