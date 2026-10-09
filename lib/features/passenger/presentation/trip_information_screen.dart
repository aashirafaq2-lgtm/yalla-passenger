import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';
import 'schedule_success_screen.dart';

class TripInformationScreen extends StatefulWidget {
  final dynamic rideData;
  const TripInformationScreen({super.key, this.rideData});

  @override
  State<TripInformationScreen> createState() => _TripInformationScreenState();
}

class _TripInformationScreenState extends State<TripInformationScreen> {
  bool _isBooking = false;

  Future<void> _confirmBooking() async {
    if (_isBooking) return;
    setState(() => _isBooking = true);

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();

      if (token == null) {
        if (mounted) setState(() => _isBooking = false);
        return;
      }

      final tripId = widget.rideData?['tripId'];
      final seats = widget.rideData?['seats'] ?? 1;
      final price = widget.rideData?['price'];

      final response = await api.dio.post(
        '/bookings/create',
        data: {
          'type': tripId != null ? 'SCHEDULED_SEAT' : 'PRIVATE_CAR',
          'tripId': tripId,
          'seatsBooked': seats,
          'totalPrice': price != null ? int.tryParse(price.toString()) : null,
          'from': widget.rideData?['from'] ?? '',
          'to': widget.rideData?['to'] ?? '',
          'pickupName': widget.rideData?['from'] ?? 'Pickup',
          'dropName': widget.rideData?['to'] ?? 'Destination',
          'fromGovernorateId': widget.rideData?['fromGovernorateId'],
          'toGovernorateId': widget.rideData?['toGovernorateId'],
        },
        options: api.authOptions(token),
      );

      if (mounted) setState(() => _isBooking = false);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final rideResp = response.data['ride'] ?? response.data['booking'];
        if (rideResp != null && rideResp['id'] != null && rideResp['departureTime'] != null) {
          try {
            final dt = DateTime.parse(rideResp['departureTime'].toString());
            NotificationService.scheduleRideReminders(dt, rideResp['id'].toString());
          } catch (_) {}
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduleSuccessScreen(
                from: rideResp?['from'] ?? widget.rideData?['from'] ?? '',
                to: rideResp?['to'] ?? widget.rideData?['to'] ?? '',
                driverName: rideResp?['driverName'] ?? widget.rideData?['driverName'] ?? '',
                totalPrice: rideResp?['totalPrice']?.toString() ?? price?.toString() ?? '',
                departureTime: rideResp?['departureTime'],
              ),
            ),
          );
        }
      } else {
        final err = response.data?['error'] ?? 'Booking failed. Please try again.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      debugPrint('[TripInfo] Booking error: $e');
      if (mounted) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final String driverName = widget.rideData?['driverName'] ?? (isArabic ? 'كابتن الرحلة' : 'Assigned Driver');
    final String carModel   = widget.rideData?['carModel']   ?? '--';
    final String plate      = widget.rideData?['plate']      ?? '---';
    final String from       = widget.rideData?['from']       ?? (isArabic ? 'نقطة الانطلاق' : 'Pickup');
    final String to         = widget.rideData?['to']         ?? (isArabic ? 'وجهة الوصول' : 'Drop-off');
    final int seats         = widget.rideData?['seats'] ?? 1;
    final bool frontSeat    = widget.rideData?['frontSeat'] ?? false;
    final String rawPrice   = widget.rideData?['price']?.toString() ?? '25000';
    final int priceNum      = int.tryParse(rawPrice) ?? 25000;
    final String priceStr   = '$priceNum ${isArabic ? "د.ع" : "IQD"}';

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
                          isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
                          style: TextStyle(
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            fontSize: 22, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trip Card
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
                          Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 30),
                          _buildCityBadge(to),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.event_seat_outlined, seats.toString(), isArabic ? 'المقاعد' : 'Seats'),
                          _buildInfoItem(Icons.monetization_on_outlined, priceStr, isArabic ? 'المجموع' : 'Total'),
                          _buildInfoItem(Icons.check_circle_outline, isArabic ? 'مؤكد' : 'Confirmed', isArabic ? 'الحالة' : 'Status'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Driver + plate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(isArabic ? 'الكابتن' : 'Driver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                              Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
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
                                  child: Text(isArabic ? 'العراق' : 'IRAQ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                                const SizedBox(width: 10),
                                Text(plate == '---' ? '١٢٣٤٥' : plate, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Price Breakdown
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تفاصيل السعر' : 'Price Details',
                        style: TextStyle(fontFamily: isArabic ? 'NotoKufiArabic' : null, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        isArabic ? '$seats × مقعد' : '$seats × seat',
                        '${seats * 25000} ${isArabic ? "د.ع" : "IQD"}',
                      ),
                      if (frontSeat) ...[
                        const SizedBox(height: 10),
                        _buildPriceRow(
                          isArabic ? 'المقعد الأمامي' : 'Front seat',
                          '5,000 ${isArabic ? "د.ع" : "IQD"}',
                        ),
                      ],
                      const Divider(height: 30),
                      _buildPriceRow(
                        isArabic ? 'الإجمالي' : 'Total',
                        priceStr,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppColors.primaryOrange.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: _isBooking ? null : _confirmBooking,
                    child: _isBooking
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                              SizedBox(width: 12),
                              Text('Booking...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            ],
                          )
                        : Text(
                            isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
                            style: TextStyle(
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cancel Button
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      isArabic ? 'رجوع' : 'Go Back',
                      style: TextStyle(
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
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

  Widget _buildCityBadge(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Text(city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 26, color: AppColors.primaryOrange),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 11)),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 17 : 15,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: isTotal ? Colors.black : Colors.black54,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 17 : 15,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          color: isTotal ? AppColors.primaryOrange : Colors.black,
        )),
      ],
    );
  }
}
