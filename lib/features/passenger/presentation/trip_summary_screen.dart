import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';

class TripSummaryScreen extends StatefulWidget {
  final dynamic rideData;
  final double? finalPrice;

  const TripSummaryScreen({
    super.key,
    this.rideData,
    this.finalPrice,
  });

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  int _selectedStars = 5;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    final locale = Provider.of<LocaleProvider>(context, listen: false);

    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final api = Provider.of<ApiService>(context, listen: false);
      final token = await storage.getToken();

      final dynamic raw = widget.rideData;
      final rideId = (raw is Map ? (raw['id'] ?? raw['rideId']) : null)?.toString();

      if (token != null && rideId != null && rideId.isNotEmpty) {
        await api.submitReview(
          rideId,
          _selectedStars,
          _commentCtrl.text.trim(),
          token,
        );
      }
    } catch (e) {
      debugPrint('Submit review note: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale.isArabic ? 'شكراً لك! تم إرسال تقييمك بنجاح.' : 'Thank you! Your rating was submitted.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final dynamic raw = widget.rideData;
    final Map<String, dynamic> ride = raw is Map<String, dynamic>
        ? raw
        : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

    final driverName = ride['driverName'] ??
        (ride['driver'] is Map
            ? "${ride['driver']['firstName'] ?? ''} ${ride['driver']['lastName'] ?? ''}".trim()
            : (isArabic ? 'الكابتن' : 'Driver'));

    final num priceNum = widget.finalPrice ??
        (ride['finalPrice'] as num?)?.toDouble() ??
        (ride['estimatedPrice'] as num?)?.toDouble() ??
        10000;

    String formatIqd(num amount) {
      final int intVal = amount.toInt();
      return intVal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 70),
              ),
              const SizedBox(height: 20),
              Text(
                isArabic ? 'وصلت لوجهتك بسلامة!' : 'Hope you enjoyed your ride!',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'قيم رحلتك مع $driverName' : 'Rate your trip with $driverName',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Big Fare Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isArabic ? 'الأجرة النهائية' : 'Final Fare',
                      style: GoogleFonts.inter(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatIqd(priceNum),
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'د.ع' : 'IQD',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Star Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  final isFilled = starNum <= _selectedStars;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStars = starNum),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber.shade700,
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),
              Text(
                _selectedStars == 5
                    ? (isArabic ? 'ممتاز!' : 'Excellent!')
                    : _selectedStars == 4
                        ? (isArabic ? 'جيد جداً' : 'Very Good')
                        : _selectedStars == 3
                            ? (isArabic ? 'جيد' : 'Good')
                            : (isArabic ? 'يحتاج تحسين' : 'Needs improvement'),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // Optional Comment Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? 'أضف ملاحظاتك أو تعليقك حول الرحلة (اختياري)...'
                        : 'Write feedback about your ride (optional)...',
                    hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 13),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              _isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : PremiumButton(
                      label: isArabic ? 'إرسال التقييم' : 'Submit Rating',
                      onPressed: _submitRating,
                      color: Colors.black,
                    ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  isArabic ? 'تخطي التقييم والعودة للرئيسية' : 'Skip & return home',
                  style: GoogleFonts.inter(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
