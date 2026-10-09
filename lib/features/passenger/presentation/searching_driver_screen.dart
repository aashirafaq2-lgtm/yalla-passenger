import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'active_ride_screen.dart';
import 'passenger_main_screen.dart';

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
  Timer? _pollTimer;
  bool _terminalRideHandled = false;

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

  void _onDriverAcceptedAction(dynamic driverData) {
    if (!mounted || _driverAccepted) return;
    _driverAccepted = true;
    _pollTimer?.cancel();

    // Play premium Uber-style driver found chime
    try {
      SoundService().playRideAccepted();
    } catch (_) {}

    // Merge driver acceptance data with original ride data
    final mergedData = Map<String, dynamic>.from(widget.rideData ?? {});
    if (driverData is Map) {
      mergedData.addAll(Map<String, dynamic>.from(driverData));
    }
    mergedData['rideId'] ??= mergedData['id'] ?? _activeRideId;
    mergedData['id'] ??= mergedData['rideId'] ?? _activeRideId;

    if (driverData is Map) {
      if (driverData['driver'] != null) {
        final d = driverData['driver'];
        mergedData['driverName'] ??= '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
        mergedData['driverPhone'] ??= d['phone'];
        if (d['vehicle'] != null) {
          final v = d['vehicle'];
          mergedData['carModel'] ??= '${v['make'] ?? ''} ${v['model'] ?? ''}'.trim();
          mergedData['plate'] ??= v['licensePlate'];
        }
      } else {
        // Fallback to top-level fields provided by getActiveRide
        if (driverData['driverName'] != null) mergedData['driverName'] = driverData['driverName'];
        if (driverData['driverPhone'] != null) mergedData['driverPhone'] = driverData['driverPhone'];
        if (driverData['carModel'] != null) mergedData['carModel'] = driverData['carModel'];
        if (driverData['plate'] != null) mergedData['plate'] = driverData['plate'];
      }
    }

    // Trigger local push notification in Android notification bar
    try {
      NotificationService.notifyRideAccepted(
        driverName: mergedData['driverName']?.toString(),
        carModel: mergedData['carModel']?.toString(),
        plate: mergedData['plate']?.toString(),
      );
    } catch (e) {
      debugPrint('[SearchingDriverScreen] Local notification error: $e');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ActiveRideScreen(rideData: mergedData)),
    );
  }

  void _dispatchRealtimeRideRequest() async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    await socketService.connect();
    if (!mounted) return;

    final rideId = _activeRideId ?? 'ride_${DateTime.now().millisecondsSinceEpoch}';
    _activeRideId = rideId;

    // The REST creation endpoint is the sole dispatcher. This screen only
    // subscribes to the persisted ride so it cannot create duplicate requests.
    socketService.onRideAccepted = _onDriverAcceptedAction;
    socketService.onRideCancelled = _handleRideCancelled;
    socketService.joinRide(rideId);

    // Direct room and broadcast event listeners
    socketService.socket?.on('ride_accepted_$rideId', (data) {
      _onDriverAcceptedAction(data);
    });
    socketService.socket?.on('ride_accepted', (data) {
      if (data is Map && (data['id']?.toString() == rideId || data['rideId']?.toString() == rideId)) {
        _onDriverAcceptedAction(data);
      }
    });

    // REST remains the source-of-truth fallback if the socket is interrupted.
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      if (!mounted || _driverAccepted) return;
      try {
        final api = Provider.of<ApiService>(context, listen: false);
        final token = await storageService.getToken();
        if (token != null) {
          final res = await api.getActiveRide(token);
          if (res.statusCode == 200 && res.data?['activeRide'] != null) {
            final activeRide = res.data['activeRide'];
            final status = activeRide['status']?.toString() ?? '';
            if (['ACCEPTED', 'ARRIVED', 'PICKED_UP', 'ONGOING', 'TRIPPING'].contains(status)) {
              _onDriverAcceptedAction(activeRide);
              return;
            }
          }
          
          if (_activeRideId != null) {
            final rideResponse = await api.getRide(_activeRideId!, token);
            final ride = rideResponse.data?['ride'] ?? rideResponse.data;
            if (ride is Map) {
              final status = ride['status']?.toString() ?? '';
              if (['ACCEPTED', 'ARRIVED', 'PICKED_UP', 'ONGOING', 'TRIPPING'].contains(status)) {
                _onDriverAcceptedAction(ride);
              } else if (['CANCELLED', 'NO_DRIVER_FOUND', 'COMPLETED'].contains(status)) {
                _handleRideCancelled({'rideId': _activeRideId, 'status': status, 'reason': status});
              }
            }
          }
        }
      } catch (_) {}
    });

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

  void _handleRideCancelled(dynamic data) {
    if (!mounted || _terminalRideHandled || data is! Map) return;
    if (data['rideId']?.toString() != _activeRideId) return;
    _terminalRideHandled = true;
    _pollTimer?.cancel();
    final reason = data['reason']?.toString() ?? 'The ride was cancelled.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
      (route) => false,
    );
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
      // Go to home screen — not login/auth screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.onRideAccepted = null;
    socket.onRideCancelled = null;
    if (_activeRideId != null) socket.socket?.off('ride_accepted_$_activeRideId');
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
