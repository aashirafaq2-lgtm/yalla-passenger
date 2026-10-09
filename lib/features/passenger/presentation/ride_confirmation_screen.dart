import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/api_service.dart';
import 'searching_driver_screen.dart';
import 'payment_method_screen.dart';

class RideConfirmationScreen extends StatefulWidget {
  final String serviceType;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final String? pickupName;
  final String? dropName;
  final int? estimatedPrice;
  final String? estimatedDistance;
  final String? estimatedTime;

  const RideConfirmationScreen({
    super.key,
    required this.serviceType,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.pickupName,
    this.dropName,
    this.estimatedPrice,
    this.estimatedDistance,
    this.estimatedTime,
  });

  @override
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> {
  String _selectedPayment = 'Cash';
  bool _isLoading = false;

  Future<void> _confirmRide() async {
    setState(() => _isLoading = true);
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final api = Provider.of<ApiService>(context, listen: false);
      final token = await storage.getToken();
      final locale = Provider.of<LocaleProvider>(context, listen: false);
      final isArabic = locale.isArabic;

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic ? 'يرجى تسجيل الدخول أولاً' : 'Please sign in first'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Create ride in DB first — get back rideId + OTP
      final res = await api.requestRide({
        'pickupLat': widget.pickupLat ?? 33.3412,
        'pickupLng': widget.pickupLng ?? 44.4009,
        'dropLat': widget.dropLat ?? 33.3500,
        'dropLng': widget.dropLng ?? 44.4100,
        'pickupName': widget.pickupName ?? 'Pickup Location',
        'dropName': widget.dropName ?? 'Destination',
        'estimatedPrice': widget.estimatedPrice ?? 10000,
        'serviceType': widget.serviceType,
        'paymentMethod': _selectedPayment,
      }, token);

      if (!mounted) return;

      final rideId = res.data?['rideId']?.toString() ?? res.data?['ride']?['id']?.toString();
      final otp = res.data?['otp']?.toString() ?? res.data?['ride']?['otp']?.toString();

      final rideData = <String, dynamic>{
        'id': rideId,
        'rideId': rideId,
        'otp': otp,
        'pickupLat': widget.pickupLat ?? 33.3412,
        'pickupLng': widget.pickupLng ?? 44.4009,
        'dropLat': widget.dropLat ?? 33.3500,
        'dropLng': widget.dropLng ?? 44.4100,
        'pickupName': widget.pickupName ?? 'Pickup Location',
        'dropName': widget.dropName ?? 'Destination',
        'estimatedPrice': widget.estimatedPrice ?? 10000,
        'serviceType': widget.serviceType,
        'paymentMethod': _selectedPayment,
        ...(res.data is Map ? Map<String, dynamic>.from(res.data) : {}),
      };

      Navigator.pop(context); // Close bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchingDriverScreen(rideData: rideData)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final locale = Provider.of<LocaleProvider>(context, listen: false);
      final msg = e.response?.data?['error']?.toString()
          ?? (locale.isArabic ? 'فشل إرسال الطلب. حاول مرة أخرى.' : 'Request failed. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final fareDisplay = widget.estimatedPrice != null
        ? '${_formatIqd(widget.estimatedPrice!)} ${isArabic ? 'د.ع' : 'IQD'}'
        : (isArabic ? '١٠,٠٠٠ د.ع' : 'IQD 10,000');
    final distDisplay = widget.estimatedDistance ?? (isArabic ? '-- كم' : '-- km');
    final timeDisplay = widget.estimatedTime ?? (isArabic ? '-- دقيقة' : '-- mins');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'تأكيد الرحلة' : 'Confirm Ride',
                  style: TextStyle(
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.serviceType,
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Route info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _routeRow(
                    icon: Icons.radio_button_checked,
                    iconColor: const Color(0xFF4CAF50),
                    text: widget.pickupName ?? (isArabic ? 'موقع الانطلاق' : 'Pickup Location'),
                    isArabic: isArabic,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      children: List.generate(3, (_) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 2, height: 6,
                        color: Colors.black12,
                      )),
                    ),
                  ),
                  _routeRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.primaryOrange,
                    text: widget.dropName ?? (isArabic ? 'الوجهة' : 'Destination'),
                    isArabic: isArabic,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fare details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.07)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(isArabic ? 'الأجرة التقديرية' : 'Estimated Fare', fareDisplay,
                      isBold: true, isArabic: isArabic),
                  const SizedBox(height: 10),
                  _buildDetailRow(isArabic ? 'المسافة' : 'Distance', distDisplay, isArabic: isArabic),
                  const SizedBox(height: 10),
                  _buildDetailRow(isArabic ? 'الوقت المتوقع' : 'Est. Time', timeDisplay, isArabic: isArabic),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.07)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primaryOrange, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    isArabic && _selectedPayment == 'Cash' ? 'نقداً' : _selectedPayment,
                    style: TextStyle(
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
                    },
                    child: Text(
                      isArabic ? 'تغيير' : 'Change',
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  disabledBackgroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 4,
                  shadowColor: AppColors.primaryOrange.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        isArabic ? 'تأكيد مع يَلَّا' : 'Confirm with Yalla',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isArabic,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isArabic = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: isArabic ? 'NotoKufiArabic' : null,
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: isArabic ? 'NotoKufiArabic' : null,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 18 : 14,
            color: isBold ? AppColors.primaryOrange : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatIqd(int val) {
    final s = val.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}
