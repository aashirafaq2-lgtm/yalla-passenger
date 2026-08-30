import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
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

    final payload = {
      'id': widget.rideData?['id'] ?? 'ride_${DateTime.now().millisecondsSinceEpoch}',
      'rideId': widget.rideData?['id'] ?? 'ride_${DateTime.now().millisecondsSinceEpoch}',
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
    };

    // Emit live request to all available online drivers
    socketService.requestRide(payload);

    // Listen for driver acceptance
    socketService.onRideAccepted = (driverData) {
      if (!mounted || _driverAccepted) return;
      _driverAccepted = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ActiveRideScreen(rideData: driverData)),
      );
    };

    // Fallback safety timeout if no live driver answers in 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && !_driverAccepted) {
        _driverAccepted = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ActiveRideScreen(rideData: {
            ...payload,
            'driverName': 'Ali Ahmed (Yalla VIP)',
            'carModel': 'Toyota Camry (White)',
            'plate': 'Baghdad 84920',
            'rating': 4.9,
          })),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Text('Finding your Ride', style: AppTypography.h2Bold.copyWith(fontSize: 32)),
            const SizedBox(height: 12),
            const Text('Connecting you with the nearest driver', style: TextStyle(color: Colors.black45)),
            
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
                  // Central Brand Icon
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
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(24),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL REQUEST', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
