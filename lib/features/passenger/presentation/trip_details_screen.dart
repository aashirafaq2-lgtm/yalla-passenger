import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';

class TripDetailsScreen extends StatelessWidget {
  final dynamic rideData;

  const TripDetailsScreen({super.key, required this.rideData});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  String _fmtPrice(dynamic val) {
    if (val == null) return '25000 IQD';
    final n = double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    if (n == 0) return '25000 IQD';
    final s = n.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$s IQD';
  }

  String _fmtDate(dynamic iso) {
    if (iso == null) return '6 Nov 2026';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso.toString();
    }
  }

  String _fmtTime(dynamic iso) {
    if (iso == null) return '08:30 AM';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$h:$min $amPm';
    } catch (_) {
      return iso.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final dynamic ride = rideData is Map ? rideData : {};
    final dynamic rawDriver = ride['driver'];
    
    // Driver info
    final String driverFirstName = rawDriver is Map ? (rawDriver['firstName'] ?? '') : '';
    final String driverLastName = rawDriver is Map ? (rawDriver['lastName'] ?? '') : '';
    String driverName = '$driverFirstName $driverLastName'.trim();
    if (driverName.isEmpty) {
      driverName = ride['driverName'] ?? (isArabic ? 'كابتن الرحلة' : 'Ahmed Master');
    }

    final String driverPhone = (rawDriver is Map ? rawDriver['phone'] : null) ?? ride['driverPhone'] ?? '0770 123 4567';
    final dynamic vehicle = rawDriver is Map ? rawDriver['vehicle'] : null;
    final String plate = (vehicle is Map ? vehicle['licensePlate'] : null) ?? ride['plate'] ?? '١٢٣٤٥';

    // Route info
    final String from = ride['pickupName'] ?? ride['originName'] ?? ride['from'] ?? (isArabic ? 'كركوك' : 'Kirkuk');
    final String to = ride['dropName'] ?? ride['destinationName'] ?? ride['to'] ?? (isArabic ? 'الموصل' : 'Mosul');

    final int seats = ride['seatsBooked'] ?? ride['seats'] ?? 1;
    final dynamic rawPrice = ride['finalPrice'] ?? ride['estimatedPrice'] ?? ride['totalPrice'] ?? ride['price'] ?? 25000;
    final String priceStr = _fmtPrice(rawPrice);

    final String tripDate = _fmtDate(ride['requestedAt'] ?? ride['createdAt'] ?? ride['date']);
    final String tripTime = _fmtTime(ride['departureTime'] ?? ride['time'] ?? ride['requestedAt'] ?? ride['createdAt']);

    final String status = (ride['status'] ?? 'CONFIRMED').toString().toUpperCase();
    String displayStatus = isArabic ? 'مؤكد' : 'Confirmed';
    if (status == 'PENDING_ADMIN' || status == 'REQUESTED' || status == 'PENDING') {
      displayStatus = isArabic ? 'قيد الانتظار' : 'Pending';
    } else if (status == 'COMPLETED') {
      displayStatus = isArabic ? 'مكتمل' : 'Completed';
    } else if (status == 'CANCELLED') {
      displayStatus = isArabic ? 'ملغي' : 'Cancelled';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Back button bar
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isArabic ? 'تفاصيل الرحلة' : 'Trip Details',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 20),

              // Main Details Card (Image 5 replica)
              FadeInDown(
                duration: const Duration(milliseconds: 350),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Route Pills Bar: [ Kirkuk ] -> [ Mosul ]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRoutePill(from),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              isArabic ? Icons.arrow_back : Icons.arrow_forward,
                              size: 22,
                              color: Colors.black54,
                            ),
                          ),
                          _buildRoutePill(to),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 3 Summary Columns: Seats, Total, Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            icon: Icons.airline_seat_recline_normal_rounded,
                            value: '$seats',
                            label: isArabic ? 'مقاعد' : 'Seats',
                          ),
                          _buildSummaryItem(
                            icon: Icons.monetization_on_outlined,
                            value: priceStr,
                            label: isArabic ? 'الإجمالي' : 'Total',
                          ),
                          _buildSummaryItem(
                            icon: Icons.check_circle_outline,
                            value: displayStatus,
                            label: isArabic ? 'الحالة' : 'Status',
                            valueColor: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 20),

                      // Driver Row & Iraqi Plate Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 28, color: Colors.black45),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'الكابتن' : 'Driver',
                                  style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  driverName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          // Iraqi Plate Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black87, width: 1.6),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_car_filled_outlined, size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'IRAQ',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  plate,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Phone Pill + Trip Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Clickable Phone Call Button
                          InkWell(
                            onTap: () => _makePhoneCall(driverPhone),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 17, color: AppColors.primaryOrange),
                                  const SizedBox(width: 8),
                                  Text(
                                    driverPhone,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Trip Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.black45),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(isArabic ? 'تاريخ الرحلة' : 'Trip Date', style: const TextStyle(fontSize: 10, color: Colors.black45)),
                                  Text(tripDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Trip Time
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 18, color: Colors.black45),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(isArabic ? 'وقت الانطلاق' : 'Trip Time', style: const TextStyle(fontSize: 10, color: Colors.black45)),
                              Text(tripTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Price Details Breakdown Card (Image 5 replica)
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تفاصيل السعر' : 'Price Details',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? '$seats × مقعد' : '$seats × seat',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            priceStr,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'الإجمالي' : 'Total',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            priceStr,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildRoutePill(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primaryOrange),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

