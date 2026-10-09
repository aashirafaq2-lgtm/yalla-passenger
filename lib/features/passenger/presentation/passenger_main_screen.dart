import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_home_screen.dart';
import 'passenger_trips_screen.dart';
import 'passenger_profile_screen.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/socket_service.dart';
import 'active_ride_screen.dart';
import 'searching_driver_screen.dart';

class PassengerMainScreen extends StatefulWidget {
  const PassengerMainScreen({super.key});

  @override
  State<PassengerMainScreen> createState() => _PassengerMainScreenState();
}

class _PassengerMainScreenState extends State<PassengerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PassengerHomeScreen(),
    const PassengerTripsScreen(),
    const PassengerProfileScreen(),
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveRide();
    });
  }

  Future<void> _checkActiveRide() async {
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final api = Provider.of<ApiService>(context, listen: false);
      final socket = Provider.of<SocketService>(context, listen: false);
      await socket.connect();

      final token = await storage.getToken();
      if (token == null) return;

      final res = await api.getActiveRide(token);
      if (res.statusCode == 200 && res.data != null && res.data['activeRide'] != null) {
        final r = res.data['activeRide'];
        if (['ACCEPTED', 'STARTED', 'ARRIVED', 'PICKED_UP', 'ONGOING', 'TRIPPING'].contains(r['status'])) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ActiveRideScreen(rideData: r)));
        } else if (r['status'] == 'REQUESTED') {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchingDriverScreen(rideData: r)));
        }
      }
    } catch (e) {
      debugPrint('[PassengerMain] Active ride check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E20),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Builder(
                builder: (context) {
                  final localeProvider = Provider.of<LocaleProvider>(context);
                  return Row(
                    children: [
                      _DarkNavItem(
                        icon: Icons.home_rounded,
                        outlineIcon: Icons.home_outlined,
                        label: localeProvider.tr('home'),
                        selected: _selectedIndex == 0,
                        isFirst: true,
                        onTap: () => _onNavTap(0),
                      ),
                      _DarkNavItem(
                        icon: Icons.directions_car_filled_rounded,
                        outlineIcon: Icons.directions_car_outlined,
                        label: localeProvider.tr('my_trips'),
                        selected: _selectedIndex == 1,
                        isFirst: false,
                        onTap: () => _onNavTap(1),
                      ),
                      _DarkNavItem(
                        icon: Icons.person_rounded,
                        outlineIcon: Icons.person_outline_rounded,
                        label: localeProvider.tr('profile'),
                        selected: _selectedIndex == 2,
                        isFirst: false,
                        onTap: () => _onNavTap(2),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ── Angled Clipper for Selected Nav Tab ───────────────────────────────────────
class _NavSelectedClipper extends CustomClipper<Path> {
  final bool isFirst;
  _NavSelectedClipper({required this.isFirst});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isFirst) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - 16, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(16, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - 16, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Dark Nav Bar Item ────────────────────────────────────────────────────────
class _DarkNavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool selected;
  final bool isFirst;
  final VoidCallback onTap;

  const _DarkNavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.selected,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: selected
            ? ClipPath(
                clipper: _NavSelectedClipper(isFirst: isFirst),
                child: Container(
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE85400), Color(0xFFFF6600)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(outlineIcon, color: const Color(0xFF9E9E9E), size: 22),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
