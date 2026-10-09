import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_main_screen.dart';

class ScheduleSuccessScreen extends StatelessWidget {
  final String from;
  final String to;
  final String driverName;
  final String totalPrice;
  final dynamic departureTime;

  const ScheduleSuccessScreen({
    super.key,
    this.from = '',
    this.to = '',
    this.driverName = '',
    this.totalPrice = '',
    this.departureTime,
  });

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month}/${dt.year} at $hour:$min $amPm';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;
    final timeStr = _formatTime(departureTime);

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Column(
        children: [
          // White Card
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: double.infinity,
              height: size.height * 0.78,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    isArabic ? '🎉 تم تأكيد حجزك!' : '🎉 Booking Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Success Checkmark
                  ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        border: Border.all(color: AppColors.primaryOrange, width: 5),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 70,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Booking details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.07)),
                    ),
                    child: Column(
                      children: [
                        if (from.isNotEmpty && to.isNotEmpty)
                          _detailRow(
                            Icons.route,
                            isArabic ? 'المسار' : 'Route',
                            '$from → $to',
                          ),
                        if (driverName.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailRow(
                            Icons.person_outline,
                            isArabic ? 'الكابتن' : 'Driver',
                            driverName,
                          ),
                        ],
                        if (totalPrice.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailRow(
                            Icons.monetization_on_outlined,
                            isArabic ? 'المبلغ' : 'Total',
                            '$totalPrice ${isArabic ? "د.ع" : "IQD"}',
                          ),
                        ],
                        if (timeStr.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailRow(
                            Icons.schedule,
                            isArabic ? 'وقت المغادرة' : 'Departure',
                            timeStr,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic ? 'شكراً لاستخدامك ' : 'Thank you for using ',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'يَلَّا',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        isArabic ? 'العودة للرئيسية' : 'Back to Home',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryOrange),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
