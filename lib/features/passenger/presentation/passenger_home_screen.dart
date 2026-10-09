import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/locale_provider.dart';
import 'find_trip_screen.dart';
import 'schedule_trip_list_screen.dart';
import 'parcel_type_screen.dart';
import 'book_entire_car_screen.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: Top Bar with Logo & Language Dropdown ───────────────
            const SizedBox(height: 12),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // YALLA Logo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic ? 'يَلَّا ' : 'YALLA ',
                          style: isArabic
                              ? GoogleFonts.notoKufiArabic(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFF5E00),
                                )
                              : GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: const Color(0xFFFF5E00),
                                ),
                        ),
                        Text(
                          isArabic ? 'YALLA' : 'يَلَّا',
                          style: isArabic
                              ? GoogleFonts.outfit(
                                  fontSize: 22,
                                  color: const Color(0xFF1C1C1E),
                                  fontWeight: FontWeight.bold,
                                )
                              : GoogleFonts.notoKufiArabic(
                                  fontSize: 22,
                                  color: const Color(0xFFFF5E00),
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ],
                    ),

                    // Modern Language Dropdown / Toggle Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: isArabic ? 'ar' : 'en',
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFFFF5E00)),
                          borderRadius: BorderRadius.circular(16),
                          items: [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇮🇶', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'العربية',
                                    style: GoogleFonts.notoKufiArabic(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isArabic ? const Color(0xFFFF5E00) : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇬🇧', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'English',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: !isArabic ? const Color(0xFFFF5E00) : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (langCode) {
                            if (langCode != null) {
                              locale.setLocale(Locale(langCode));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Cards List ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Card 1 – Find a Trip (Hero Card)
                  _FindTripCard(
                    isArabic: isArabic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindTripScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 2 – Schedule a trip (02)
                  _ServiceRowCard(
                    number: '02',
                    title: isArabic ? 'رحلة مجدولة' : 'Schedule a trip',
                    subtitle: isArabic
                        ? 'خطط لرحلتك مسبقاً\nونحن نتكفل بالباقي.'
                        : 'Plan your trip in advance\nand we\'ll handle the rest.',
                    asset: 'assets/images/schedule.png',
                    delay: 150,
                    isArabic: isArabic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScheduleTripListScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 3 – Sending mail or parcels (03)
                  _ServiceRowCard(
                    number: '03',
                    title: isArabic ? 'إرسال بريد\nأو طرود' : 'Sending mail\nor parcels',
                    subtitle: isArabic
                        ? 'توصيل سريع وموثوق\nلرسائلك وطرودك.'
                        : 'Fast and reliable delivery\nfor your letters and parcels.',
                    asset: 'assets/images/parcels.png',
                    delay: 250,
                    isArabic: isArabic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParcelTypeScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 4 – Book the entire car (04)
                  _ServiceRowCard(
                    number: '04',
                    title: isArabic ? 'حجز\nسيارة كاملة' : 'Book the\nentire car',
                    subtitle: isArabic
                        ? 'احجز السيارة بالكامل\nلك ولمجموعتك.'
                        : 'Book the whole car for\nyou and your group.',
                    asset: 'assets/images/outside.png',
                    delay: 350,
                    isArabic: isArabic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookEntireCarScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero "Find a Trip" Card ──────────────────────────────────────────────────
class _FindTripCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isArabic;
  const _FindTripCard({required this.onTap, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 215,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  'assets/images/trips.png',
                  fit: BoxFit.cover,
                  alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                ),

                // Smooth warm white gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                      colors: [
                        const Color(0xFFFAF9F6).withOpacity(0.98),
                        const Color(0xFFFAF9F6).withOpacity(0.92),
                        const Color(0xFFFAF9F6).withOpacity(0.40),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.44, 0.65, 1.0],
                    ),
                  ),
                ),

                // Orange accent arc
                Positioned(
                  top: -24,
                  left: isArabic ? null : -24,
                  right: isArabic ? -24 : null,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),

                // Bottom curved orange accent wave
                Positioned(
                  bottom: -15,
                  left: isArabic ? null : -15,
                  right: isArabic ? -15 : null,
                  child: Container(
                    width: 105,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00).withOpacity(0.9),
                      borderRadius: BorderRadius.only(
                        topRight: isArabic ? Radius.zero : const Radius.circular(55),
                        topLeft: isArabic ? const Radius.circular(55) : Radius.zero,
                        bottomLeft: isArabic ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isArabic ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Content Column
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isArabic ? 16 : 20,
                    22,
                    isArabic ? 20 : 16,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'ابحث عن\nرحلة الآن!' : 'Find a\nTrip now!',
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: isArabic
                            ? GoogleFonts.notoKufiArabic(
                                color: const Color(0xFF1C1C1E),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              )
                            : GoogleFonts.outfit(
                                color: const Color(0xFF1C1C1E),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? 'ابحث عن رحلات قريبة\nواحجز فوراً'
                            : 'Find nearby rides\nand book instantly',
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF6E6E73),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      const Spacer(),
                      _OrangePillButton(
                        label: isArabic ? 'ابحث عن رحلة' : 'Find a Trip now',
                        onTap: onTap,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Orange Pill CTA Button ───────────────────────────────────────────────────
class _OrangePillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isArabic;
  const _OrangePillButton({required this.label, required this.onTap, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6600), Color(0xFFE85400)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5E00).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isArabic
              ? [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFFFF5E00),
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.notoKufiArabic(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                ]
              : [
                  const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFFF5E00),
                      size: 13,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

// ── Angled Arrow Wedge Clipper for Left Dark Section ─────────────────────────
class _AngledWedgeClipper extends CustomClipper<Path> {
  final bool isArabic;
  const _AngledWedgeClipper({this.isArabic = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isArabic) {
      path.moveTo(24, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(24, size.height);
      path.lineTo(0, size.height * 0.5);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - 24, 0);
      path.lineTo(size.width, size.height * 0.5);
      path.lineTo(size.width - 24, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Two-Tone Split Service Card (02, 03, 04) ─────────────────────────────────
class _ServiceRowCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final String asset;
  final int delay;
  final VoidCallback onTap;
  final bool isArabic;

  const _ServiceRowCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.delay,
    required this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 124,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Row(
              children: isArabic
                  ? [
                      // Arabic: Text on right, image on left
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: _buildTextSection(isArabic: true),
                        ),
                      ),
                      ClipPath(
                        clipper: const _AngledWedgeClipper(isArabic: true),
                        child: Container(
                          width: 124,
                          height: 124,
                          color: const Color(0xFF222224),
                          padding: const EdgeInsets.fromLTRB(22, 8, 10, 8),
                          child: Center(
                            child: Image.asset(asset, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ]
                  : [
                      // English: Image on left, text on right
                      ClipPath(
                        clipper: const _AngledWedgeClipper(),
                        child: Container(
                          width: 124,
                          height: 124,
                          color: const Color(0xFF222224),
                          padding: const EdgeInsets.fromLTRB(10, 8, 22, 8),
                          child: Center(
                            child: Image.asset(asset, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: _buildTextSection(isArabic: false),
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection({required bool isArabic}) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Badge + Vertical divider + Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isArabic
              ? [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        color: const Color(0xFF1C1C1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 14,
                    color: const Color(0xFFE0E0E0),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      number,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ]
              : [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      number,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 14,
                    color: const Color(0xFFE0E0E0),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1C1C1E),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
        ),

        // Orange accent bar under title
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 2.5,
            margin: EdgeInsets.only(left: isArabic ? 0 : 32, right: isArabic ? 32 : 0),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5E00),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Subtitle + Orange arrow button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isArabic
              ? [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6600), Color(0xFFE85400)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E00).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        color: const Color(0xFF757575),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ]
              : [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF757575),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6600), Color(0xFFE85400)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E00).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
        ),
      ],
    );
  }
}
