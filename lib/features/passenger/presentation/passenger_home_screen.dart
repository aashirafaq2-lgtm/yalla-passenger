import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'find_trip_screen.dart';
import 'schedule_trip_list_screen.dart';
import 'parcel_type_screen.dart';
import 'book_entire_car_screen.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: YALLA يلا in vibrant orange ───────────────────────
            const SizedBox(height: 16),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'YALLA ',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: const Color(0xFFFF5E00),
                    ),
                  ),
                  Text(
                    'يَلَّا',
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 28,
                      color: const Color(0xFFFF5E00),
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindTripScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 2 – Schedule a trip (02)
                  _ServiceRowCard(
                    number: '02',
                    title: 'Schedule a trip',
                    subtitle: 'Plan your trip in advance\nand we\'ll handle the rest.',
                    asset: 'assets/images/schedule.png',
                    delay: 150,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScheduleTripListScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 3 – Sending mail or parcels (03)
                  _ServiceRowCard(
                    number: '03',
                    title: 'Sending mail\nor parcels',
                    subtitle: 'Fast and reliable delivery\nfor your letters and parcels.',
                    asset: 'assets/images/parcels.png',
                    delay: 250,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParcelTypeScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 4 – Book the entire car (04)
                  _ServiceRowCard(
                    number: '04',
                    title: 'Book the\nentire car',
                    subtitle: 'Book the whole car for\nyou and your group.',
                    asset: 'assets/images/outside.png',
                    delay: 350,
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
  const _FindTripCard({required this.onTap});

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
                // Background image (Orange SUV on highway with sunset skyline)
                Image.asset(
                  'assets/images/trips.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),

                // Smooth warm white gradient on left side for text clarity
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
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

                // Top-left curved orange accent arc
                Positioned(
                  top: -24,
                  left: -24,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),

                // Bottom-left subtle curved orange accent wave
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 105,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E00).withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(55),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Content Column
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find a\nTrip now!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1C1C1E),
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find nearby rides\nand book instantly',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF6E6E73),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      _OrangePillButton(label: 'Find a Trip now', onTap: onTap),
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
  const _OrangePillButton({required this.label, required this.onTap});

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
          children: [
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
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 24, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width - 24, size.height);
    path.lineTo(0, size.height);
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

  const _ServiceRowCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.delay,
    required this.onTap,
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
              children: [
                // ── Left: Dark Charcoal Angled Wedge with 3D Image ──
                ClipPath(
                  clipper: _AngledWedgeClipper(),
                  child: Container(
                    width: 124,
                    height: 124,
                    color: const Color(0xFF222224),
                    padding: const EdgeInsets.fromLTRB(10, 8, 22, 8),
                    child: Center(
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // ── Right: White section with badge, title, bar, subtitle, arrow ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge + Vertical divider + Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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
                        Container(
                          width: 22,
                          height: 2.5,
                          margin: const EdgeInsets.only(left: 32),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5E00),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Subtitle + Orange arrow button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                    ),
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
