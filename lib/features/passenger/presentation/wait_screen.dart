import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'active_ride_screen.dart';
import 'passenger_main_screen.dart';

class WaitScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData;
  const WaitScreen({super.key, this.rideData});

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _driverAccepted = false;
  String? _rideId;
  Timer? _pollTimer;
  int _dotsCount = 1;
  Timer? _dotsTimer;
  bool _terminalRideHandled = false;

  @override
  void initState() {
    super.initState();

    // Extract rideId from passed rideData
    _rideId = (widget.rideData?['id'] ?? widget.rideData?['rideId'])?.toString();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dotsCount = (_dotsCount % 3) + 1);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSocketAndPoll();
    });
  }

  void _initSocketAndPoll() async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    await socketService.connect();
    if (!mounted) return;

    // ── Join ride room on socket ──
    if (_rideId != null) {
      socketService.joinRide(_rideId!);
    }

    // ── Emit ride request on socket (so drivers get notified) ──
    // Ride creation already dispatched this persisted request through the API.

    // ── Socket: ride_accepted ──
    socketService.onRideAccepted = (data) {
      if (!mounted || _driverAccepted) return;
      _navigateToActiveRide(data);
    };
    socketService.onRideCancelled = _handleRideCancelled;

    if (_rideId != null) {
      socketService.socket?.on('ride_accepted_$_rideId', (data) {
        if (!mounted || _driverAccepted) return;
        _navigateToActiveRide(data);
      });
    }

    // ── API Polling every 1.5 seconds (Fail-safe auto-transition) ──
    await _pollForActiveRide(storageService);
    if (!mounted || _driverAccepted) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _driverAccepted) return;
      await _pollForActiveRide(storageService);
    });

    // ── 60s timeout: no driver found ──
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && !_driverAccepted) {
        _showNoDriverDialog();
      }
    });
  }

  Future<void> _pollForActiveRide(StorageService storage) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) return;

      final res = await api.getActiveRide(token);
      if (res.statusCode == 200 && res.data?['activeRide'] != null) {
        final ride = res.data['activeRide'];
        final status = ride['status']?.toString() ?? '';
        // If driver accepted, move on
        if (['ACCEPTED', 'ARRIVED', 'PICKED_UP', 'ONGOING', 'TRIPPING']
            .contains(status)) {
          _navigateToActiveRide(ride);
        }
      } else if (_rideId != null) {
        final rideResponse = await api.getRide(_rideId!, token);
        final ride = rideResponse.data?['ride'];
        if (ride is Map && ['CANCELLED', 'NO_DRIVER_FOUND', 'COMPLETED'].contains(ride['status'])) {
          _handleRideCancelled({'rideId': _rideId, 'status': ride['status'], 'reason': ride['status']});
        }
      }
    } catch (_) {}
  }

  void _handleRideCancelled(dynamic data) {
    if (!mounted || _terminalRideHandled || data is! Map) return;
    if (data['rideId']?.toString() != _rideId) return;
    _terminalRideHandled = true;
    _pollTimer?.cancel();
    _dotsTimer?.cancel();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
      (route) => false,
    );
  }

  void _navigateToActiveRide(dynamic data) {
    if (_driverAccepted || !mounted) return;
    _driverAccepted = true;

    try {
      SoundService().playRideAccepted();
    } catch (_) {}

    // ── Uber-style push notification: driver accepted ──────────────────────
    try {
      final driverName = data is Map
          ? (data['driverName'] ?? data['driver']?['firstName'] ?? 'Your Driver')
          : 'Your Driver';
      final carModel = data is Map ? (data['carModel'] ?? '') : '';
      final plate = data is Map ? (data['plate'] ?? '') : '';
      NotificationService.notifyRideAccepted(
        driverName: driverName.toString(),
        carModel: carModel.toString(),
        plate: plate.toString(),
      );
    } catch (_) {}

    final mergedData = <String, dynamic>{};
    if (widget.rideData != null) mergedData.addAll(widget.rideData!);
    if (data is Map) mergedData.addAll(Map<String, dynamic>.from(data));

    // Ensure we have rideId
    mergedData['rideId'] ??= mergedData['id'] ?? _rideId;
    mergedData['id'] ??= mergedData['rideId'] ?? _rideId;

    // Extract driver info from nested 'driver' object if present
    if (data is Map && data['driver'] != null) {
      final d = data['driver'];
      mergedData['driverName'] ??= '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
      mergedData['driverPhone'] ??= d['phone'];
      mergedData['rating'] ??= d['rating']?.toString() ?? '5.0';
      if (d['vehicle'] != null) {
        mergedData['carModel'] ??= '${d['vehicle']['make'] ?? ''} ${d['vehicle']['model'] ?? ''}'.trim();
        mergedData['plate'] ??= d['vehicle']['licensePlate'];
      }
    }
    if (data is Map && data['passenger'] != null) {
      final p = data['passenger'];
      mergedData['pickupLat'] ??= data['pickupLat'];
      mergedData['pickupLng'] ??= data['pickupLng'];
      mergedData['dropLat'] ??= data['dropLat'];
      mergedData['dropLng'] ??= data['dropLng'];
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => ActiveRideScreen(rideData: mergedData),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showNoDriverDialog() {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isArabic ? 'لا يوجد كباتن متاحين' : 'No Drivers Available',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? 'جميع الكباتن مشغولون حالياً. هل تريد إعادة البحث؟'
              : 'All nearby drivers are currently busy. Would you like to retry?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelRide();
            },
            child: Text(isArabic ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _driverAccepted = false);
              _initSocketAndPoll();
            },
            child: Text(isArabic ? 'إعادة البحث' : 'Retry',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRide() async {
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final api = Provider.of<ApiService>(context, listen: false);
      final token = await storage.getToken();
      if (token != null && _rideId != null) {
        await api.cancelRide(_rideId!, 'Cancelled while searching', token);
      }
    } catch (_) {}
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
        (r) => false,
      );
    }
  }

  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.onRideAccepted = null;
    socket.onRideCancelled = null;
    if (_rideId != null) socket.socket?.off('ride_accepted_$_rideId');
    _pulseController.dispose();
    _rotateController.dispose();
    _pollTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;
    final dots = '.' * _dotsCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 36),
              // ── Header Logo ──────────────────────────────────────────────
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yalla ',
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'يَلَّا',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 34,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Status Card ──────────────────────────────────────────────
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'جاري البحث$dots' : 'Searching$dots',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.primaryOrange,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isArabic
                            ? 'نحن نبحث عن أقرب كابتن لك'
                            : 'Finding the nearest captain for you',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── Animated Radar ───────────────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse rings
                    ...List.generate(3, (i) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final prog = (_pulseController.value + i / 3) % 1.0;
                          return Container(
                            width: 280 * prog,
                            height: 280 * prog,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryOrange.withOpacity((1 - prog) * 0.6),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    // Rotating dashed ring
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (_, child) => Transform.rotate(
                        angle: _rotateController.value * 6.28,
                        child: child,
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    ),
                    // Center badge
                    Pulse(
                      infinite: true,
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFF8C00), AppColors.primaryOrange],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.directions_car_rounded, color: Colors.white, size: 38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Info Row ─────────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoChip(Icons.security_rounded, isArabic ? 'آمن' : 'Safe'),
                      _infoChip(Icons.speed_rounded, isArabic ? 'سريع' : 'Fast'),
                      _infoChip(Icons.star_rounded, isArabic ? 'موثوق' : 'Reliable'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Cancel Button ─────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE5DC),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _cancelRide,
                      child: Text(
                        isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade700,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }
}
