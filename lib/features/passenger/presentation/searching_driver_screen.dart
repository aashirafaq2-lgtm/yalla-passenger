import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'active_ride_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData;
  const SearchingDriverScreen({super.key, this.rideData});

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _driverAccepted = false;
  String? _activeRideId;

  @override
  void initState() {
    super.initState();
    _activeRideId = (widget.rideData?['id'] ?? widget.rideData?['rideId'])?.toString();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dispatchRealtimeRideRequest();
    });
  }

  void _dispatchRealtimeRideRequest() async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final userId = await storageService.getUserId() ?? 'passenger_${DateTime.now().millisecondsSinceEpoch}';

    final rideId = _activeRideId ?? 'ride_${DateTime.now().millisecondsSinceEpoch}';
    _activeRideId = rideId;

    final payload = {
      'id': rideId,
      'rideId': rideId,
      'passengerId': userId,
      'passengerName': widget.rideData?['passengerName'] ?? 'Passenger',
      'passengerPhone': widget.rideData?['passengerPhone'] ?? '07700000000',
      'pickupName': widget.rideData?['pickupName'] ?? 'Current Location',
      'dropName': widget.rideData?['dropName'] ?? 'Destination',
      'pickupLat': widget.rideData?['pickupLat'] ?? 33.3152,
      'pickupLng': widget.rideData?['pickupLng'] ?? 44.3661,
      'dropLat': widget.rideData?['dropLat'] ?? 33.3000,
      'dropLng': widget.rideData?['dropLng'] ?? 44.3800,
      'estimatedPrice': widget.rideData?['estimatedPrice'] ?? 10000,
      'serviceType': widget.rideData?['serviceType'] ?? 'Economy',
      'otp': widget.rideData?['otp'],
    };

    // Emit live request to nearby drivers
    socketService.requestRide(payload);

    // Listen for driver acceptance
    socketService.onRideAccepted = (driverData) {
      if (!mounted || _driverAccepted) return;
      _driverAccepted = true;

      // Merge driver acceptance data with original ride data (e.g. otp, pickup/drop)
      final mergedData = Map<String, dynamic>.from(widget.rideData ?? {});
      if (driverData is Map) {
        mergedData.addAll(Map<String, dynamic>.from(driverData));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ActiveRideScreen(rideData: mergedData)),
      );
    };

    // Real production timeout (45s)
    Future.delayed(const Duration(seconds: 45), () {
      if (mounted && !_driverAccepted) {
        final locale = Provider.of<LocaleProvider>(context, listen: false);
        final isArabic = locale.isArabic;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isArabic ? 'لا يوجد كباتن متاحين حالياً' : 'No Drivers Available',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              isArabic
                  ? 'جميع الكباتن القريبين منك مشغولون حالياً. هل ترغب بإعادة البحث أو إلغاء الطلب؟'
                  : 'All nearby drivers are currently busy. Would you like to retry searching or cancel?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _cancelRequest();
                },
                child: Text(
                  isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _dispatchRealtimeRideRequest(); // Retry search
                },
                child: Text(
                  isArabic ? 'إعادة البحث' : 'Retry Search',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _cancelRequest() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    final token = await storage.getToken();

    if (token != null && _activeRideId != null) {
      try {
        await api.cancelRide(_activeRideId!, 'Cancelled while searching', token);
      } catch (e) {
        debugPrint('Cancel ride note: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Text(
              isArabic ? 'جاري البحث عن كابتن...' : 'Finding your Ride',
              style: AppTypography.h2Bold.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 10),
            Text(
              isArabic ? 'نقوم بالتواصل مع أقرب الكباتن المتاحين لك' : 'Connecting you with the nearest captain',
              style: GoogleFonts.inter(color: Colors.black45, fontSize: 14),
            ),

            const Spacer(),

            // Radar Animation
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        double progress = (_pulseController.value + index / 3) % 1.0;
                        return Container(
                          width: 300 * progress,
                          height: 300 * progress,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryOrange.withOpacity(1 - progress),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  // Central Brand Badge
                  Pulse(
                    infinite: true,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                      ),
                      child: const Center(
                        child: Text(
                          'يَلَّا',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: TextButton(
                onPressed: _cancelRequest,
                child: Text(
                  isArabic ? 'إلغاء الطلب' : 'CANCEL REQUEST',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16,
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
}
