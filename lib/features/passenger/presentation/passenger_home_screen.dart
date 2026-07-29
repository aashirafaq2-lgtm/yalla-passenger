import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'find_trip_screen.dart';
import 'schedule_trip_list_screen.dart';
import 'parcel_type_screen.dart';
import 'book_entire_car_screen.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SizedBox(height: 24),
            FadeInDown(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'YALLA ',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'يَلَّا',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 32,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Service Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildServiceCard(
                    context: context,
                    title: 'Find a Trip now!',
                    asset: 'assets/images/trips.png',
                    index: 1,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindTripScreen())),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: 'Schedule a trip',
                    asset: 'assets/images/schedule.png',
                    index: 2,
                    isSerif: true,
                    hasBottomOverlay: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleTripListScreen())),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: 'Sending mail or Parcels',
                    asset: 'assets/images/parcels.png',
                    index: 3,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelTypeScreen())),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: 'Book the entire car',
                    asset: 'assets/images/outside.png',
                    index: 4,
                    isItalic: true,
                    isTopLeft: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookEntireCarScreen())),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String asset,
    required int index,
    bool isSerif = false,
    bool hasBottomOverlay = false,
    bool isItalic = false,
    bool isTopLeft = false,
    VoidCallback? onTap,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 150 * index),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 145,
          margin: const EdgeInsets.only(bottom: 18),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.15),
                BlendMode.darken,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (hasBottomOverlay)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: const Color(0xFFC69A6E).withOpacity(0.8), // Exact brown/orange skin tone from design
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSerif4(
                          color: Colors.black.withOpacity(0.9),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (!hasBottomOverlay)
                  Align(
                    alignment: isTopLeft ? Alignment.topLeft : Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, isTopLeft ? 0 : 20),
                      child: Text(
                        title,
                        textAlign: isTopLeft ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: isItalic ? 'cursive' : null,
                          fontWeight: FontWeight.w900,
                          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
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


