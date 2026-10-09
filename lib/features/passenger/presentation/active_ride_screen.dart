import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_chat_screen.dart';
import 'passenger_main_screen.dart';
import 'trip_summary_screen.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveRideScreen extends StatefulWidget {
  final dynamic rideData;
  const ActiveRideScreen({super.key, this.rideData});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen>
    with SingleTickerProviderStateMixin {
  // ── Smooth marker interpolation & rotation (Uber-style) ──────────────
  late LatLng _driverPos;
  LatLng? _animFromPos;
  LatLng? _animToPos;
  AnimationController? _markerAnimCtrl;
  Animation<double>? _markerAnim;
  double _driverBearing = 0.0; // Heading in radians

  // Smoothly interpolate between two LatLng points
  LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  // Calculate angle between two points for realistic car orientation
  double _calcBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * (math.pi / 180.0);
    final lon1 = from.longitude * (math.pi / 180.0);
    final lat2 = to.latitude * (math.pi / 180.0);
    final lon2 = to.longitude * (math.pi / 180.0);
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
  }

  void _animateDriverTo(LatLng target) {
    final from = _driverPos;
    if ((from.latitude - target.latitude).abs() < 0.00001 &&
        (from.longitude - target.longitude).abs() < 0.00001) return;

    _animFromPos = from;
    _animToPos = target;
    _driverBearing = _calcBearing(from, target);

    _markerAnimCtrl?.dispose();
    _markerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _markerAnim = CurvedAnimation(
      parent: _markerAnimCtrl!,
      curve: Curves.easeInOut,
    );
    _markerAnimCtrl!.addListener(() {
      if (!mounted) return;
      setState(() {
        _driverPos = _lerpLatLng(_animFromPos!, _animToPos!, _markerAnim!.value);
      });
    });
    _markerAnimCtrl!.forward();
  }
  // ─────────────────────────────────────────────────────────────────────

  String _etaText = '';
  String _distanceText = '';
  final MapController _mapController = MapController();
  String _statusText = '';
  bool _isCompletedNavigated = false;
  List<LatLng> _routePoints = [];
  bool _isTripInProgress = false;

  late Map<String, dynamic> _rideData;

  @override
  void initState() {
    super.initState();
    final dynamic raw = widget.rideData;
    _rideData = raw is Map<String, dynamic>
        ? Map.from(raw)
        : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});
    // Use the last persisted GPS fix immediately when restoring an accepted ride.
    final dynamic driver = _rideData['driver'];
    final dynamic location = _rideData['driverLocation'] ??
        (driver is Map ? driver['location'] : null);
    final double initLat = (location is Map ? (location['lat'] as num?)?.toDouble() : null) ??
        double.tryParse(_rideData['pickupLat']?.toString() ?? '') ?? 33.3412;
    final double initLng = (location is Map ? (location['lng'] as num?)?.toDouble() : null) ??
        double.tryParse(_rideData['pickupLng']?.toString() ?? '') ?? 44.4009;
    _driverPos = LatLng(initLat, initLng);

    final socketService = Provider.of<SocketService>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _statusText = localeProvider.isArabic ? 'الكابتن في الطريق إليك' : 'Driver is on the way';
    final rideId = (raw is Map ? (raw['id'] ?? raw['rideId']) : null)?.toString();
    if (rideId != null && rideId.isNotEmpty) {
      socketService.joinRide(rideId);
    }
    _listenToSocketEvents();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoadRoute();
      _fetchRideDetails();
    });
  }

  Future<void> _fetchRideDetails() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) return;

      final res = await api.getActiveRide(token);
      if (res.statusCode == 200 && res.data?['activeRide'] != null) {
        if (mounted) {
          setState(() {
            _rideData.addAll(Map<String, dynamic>.from(res.data['activeRide']));
            final ride = res.data['activeRide'];
            final driver = ride is Map ? ride['driver'] : null;
            final location = ride is Map ? (ride['driverLocation'] ?? (driver is Map ? driver['location'] : null)) : null;
            if (location is Map && location['lat'] is num && location['lng'] is num) {
              _driverPos = LatLng((location['lat'] as num).toDouble(), (location['lng'] as num).toDouble());
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching active ride details: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _fetchRoadRoute() async {
    final Map<String, dynamic> ride = _rideData;

    final double pLat = double.tryParse(ride['pickupLat']?.toString() ?? '') ?? 33.3152;
    final double pLng = double.tryParse(ride['pickupLng']?.toString() ?? '') ?? 44.3661;
    final double dLat = double.tryParse(ride['dropLat']?.toString() ?? '') ?? 33.3300;
    final double dLng = double.tryParse(ride['dropLng']?.toString() ?? '') ?? 44.3800;

    final LatLng start = _isTripInProgress ? _driverPos : LatLng(pLat, pLng);
    final LatLng dest = LatLng(dLat, dLng);

    try {
      final dio = Dio();
      final url = 'https://api-yalla.aaaj.shop/api/map/directions?originLat=${start.latitude}&originLng=${start.longitude}&destLat=${dest.latitude}&destLng=${dest.longitude}';
      final res = await dio.get(url, options: Options(receiveTimeout: const Duration(seconds: 4)));
      if (res.statusCode == 200 && res.data != null && res.data['route'] != null) {
        final ptsStr = res.data['route']['points'] ?? '';
        if (ptsStr.isNotEmpty) {
          final decoded = _decodePolyline(ptsStr);
          if (decoded.isNotEmpty && mounted) {
            setState(() {
              _routePoints = decoded;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[Passenger Route] Note: $e');
    }

    if (mounted) {
      setState(() {
        _routePoints = [start, dest];
      });
    }
  }


  void _listenToSocketEvents() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    // Live driver moving coordinates
    socketService.onDriverMoved = (data) {
      if (!mounted) return;
      if (data is Map && data['rideId'] != null &&
          data['rideId'].toString() != (_rideData['id'] ?? _rideData['rideId']).toString()) return;
      if (data is Map && data['lat'] != null && data['lng'] != null) {
        final newPos = LatLng(
          (data['lat'] as num).toDouble(),
          (data['lng'] as num).toDouble(),
        );
        // Smooth glide instead of jump
        _animateDriverTo(newPos);
        if (data['etaMinutes'] != null) {
          final eta = (data['etaMinutes'] as num).toInt();
          final loc = Provider.of<LocaleProvider>(context, listen: false);
          setState(() {
            _etaText = eta <= 1
                ? (loc.isArabic ? 'يصل الآن' : 'Arriving now')
                : (loc.isArabic ? 'الوصول: $eta دقيقة' : 'ETA: $eta min');
          });
        }
        final distanceKm = (data['distanceToPickupKm'] as num?)?.toDouble();
        if (distanceKm != null) {
          final loc = Provider.of<LocaleProvider>(context, listen: false);
          setState(() {
            _distanceText = distanceKm < 1
                ? '${(distanceKm * 1000).round()} m'
                : '${distanceKm.toStringAsFixed(1)} km';
          });
        }
        try {
          _mapController.move(_driverPos, _mapController.camera.zoom);
        } catch (_) {}
      }
    };

    // Live ride status updates (ARRIVED, PICKED_UP, COMPLETED, CANCELLED)
    socketService.onRideStatusUpdate = (data) {
      if (!mounted) return;
      final status = data['status']?.toString() ?? '';
      final locale = Provider.of<LocaleProvider>(context, listen: false);
      final isArabic = locale.isArabic;

      setState(() {
        if (status == 'ARRIVED') {
          _statusText = isArabic ? 'وصل الكابتن إلى نقطة الانطلاق!' : 'Driver has arrived at pickup!';
          SoundService().playRideAccepted();
          // 🔔 Push Notification
          NotificationService.notifyDriverArrived();
        } else if (status == 'PICKED_UP' || status == 'ONGOING') {
          _statusText = isArabic ? 'الرحلة قيد التنفيذ' : 'Trip in progress';
          _isTripInProgress = true;
          _fetchRoadRoute();
          // 🔔 Push Notification
          NotificationService.notifyTripStarted();
        } else if (status == 'COMPLETED') {
          _statusText = isArabic ? 'اكتملت الرحلة بنجاح!' : 'Trip Completed';
        }
      });

      if (status == 'COMPLETED' && !_isCompletedNavigated) {
        _isCompletedNavigated = true;
        SoundService().playRideCompleted();
        // 🔔 Push Notification
        NotificationService.notifyTripCompleted();
        final finalPrice = (data['finalPrice'] as num?)?.toDouble();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TripSummaryScreen(
              rideData: widget.rideData,
              finalPrice: finalPrice,
            ),
          ),
        );
      } else if (status == 'CANCELLED') {
        SoundService().playRideCancelled();
        // 🔔 Push Notification
        NotificationService.notifyRideCancelled(reason: data['reason']?.toString());
        _showCancelledNotice(data['reason']?.toString() ?? '');
      }
    };

    socketService.onRideCancelled = (data) {
      if (!mounted) return;
      SoundService().playRideCancelled();
      // 🔔 Push Notification
      NotificationService.notifyRideCancelled(reason: data['reason']?.toString());
      _showCancelledNotice(data['reason']?.toString() ?? '');
    };
  }

  void _showCancelledNotice(String reason) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isAr = locale.isArabic;
    final displayReason = reason.isEmpty
        ? (isAr ? 'تم الإلغاء من قِبل الكابتن' : 'Cancelled by driver')
        : reason;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Text(
                isAr ? 'تم إلغاء الرحلة' : 'Ride Cancelled',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: isAr ? 'NotoKufiArabic' : null,
                ),
              ),
            ],
          ),
          content: Text(
            isAr
                ? 'نعتذر، تم إلغاء طلب الرحلة.\nالسبب: $displayReason'
                : 'The ride was cancelled.\nReason: $displayReason',
            style: TextStyle(
              fontSize: 14,
              fontFamily: isAr ? 'NotoKufiArabic' : null,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
                  (route) => false,
                );
              },
              child: Text(
                isAr ? 'العودة للرئيسية' : 'Return Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: isAr ? 'NotoKufiArabic' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String rideId) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    final reasons = isArabic
        ? ['الكابتن استغرق وقتاً طويلاً', 'غيرت رأيي', 'وجدت وسيلة نقل أخرى', 'أدخلت وجهة غير صحيحة']
        : ['Driver is taking too long', 'Changed my mind', 'Found alternate transport', 'Incorrect pickup location'];

    String selectedReason = reasons[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                isArabic ? 'إلغاء الرحلة' : 'Cancel Ride',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? 'يرجى اختيار سبب الإلغاء:' : 'Please choose a cancellation reason:',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...reasons.map((r) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(r, style: GoogleFonts.inter(fontSize: 14)),
                    value: r,
                    groupValue: selectedReason,
                    activeColor: AppColors.primaryOrange,
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedReason = val);
                    },
                  )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(isArabic ? 'رجوع' : 'Dismiss', style: const TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final api = Provider.of<ApiService>(context, listen: false);
                        final storage = Provider.of<StorageService>(context, listen: false);
                        final token = await storage.getToken();
                        if (token == null) return;
                        try {
                          await api.cancelRide(rideId, selectedReason, token);
                        } catch (e) {
                          debugPrint('Cancel ride note: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not cancel the ride. Check your connection and retry.')),
                            );
                          }
                          return;
                        }

                        SoundService().playRideCancelled();

                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        isArabic ? 'تأكيد الإلغاء' : 'Confirm Cancel',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showSafetySheet(String rideId, String driverName, String plate) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: Colors.red, size: 28),
                const SizedBox(width: 10),
                Text(
                  isArabic ? 'مركز الأمان والسلامة (SOS)' : 'Safety & Emergency Toolkit',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'خطوط الطوارئ المعتمدة في العراق والمساعدة الفورية:'
                  : 'Emergency hotlines in Iraq & live safety assistance:',
              style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // SOS Alert Yalla Dispatch Banner
            InkWell(
              onTap: () {
                final socketService = Provider.of<SocketService>(context, listen: false);
                socketService.socket?.emit('sos_alert', {
                  'rideId': rideId,
                  'driverName': driverName,
                  'plate': plate,
                  'lat': _driverPos.latitude,
                  'lng': _driverPos.longitude,
                  'timestamp': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: Text(
                      isArabic
                          ? '🚨 تم إرسال إشعار طوارئ SOS فوري إلى مركز عمليات يلا!'
                          : '🚨 SOS Emergency Alert sent to Yalla operations center!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'إرسال إنذار طوارئ فوري (SOS)' : 'Send Live SOS Emergency Alert',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            isArabic ? 'يخطر فريق أمان يلا مع موقعك المباشر' : 'Alerts Yalla safety team with your live GPS',
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildEmergencyTile(
              icon: Icons.local_police_rounded,
              title: isArabic ? 'شرطة النجدة (104)' : 'Police Hotline (104)',
              subtitle: isArabic ? 'اتصال فوري بشرطة النجدة العراقية' : 'Direct emergency police call',
              color: Colors.blue.shade800,
              onTap: () async {
                final uri = Uri.parse('tel:104');
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Clipboard.setData(const ClipboardData(text: '104'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تم نسخ الرقم: 104' : 'Copied emergency number: 104')),
                    );
                  }
                } catch (_) {
                  Clipboard.setData(const ClipboardData(text: '104'));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              icon: Icons.medical_services_rounded,
              title: isArabic ? 'الإسعاف الفوري (122)' : 'Medical Ambulance (122)',
              subtitle: isArabic ? 'اتصال فوري بالإسعاف الطبي' : 'Immediate medical ambulance call',
              color: Colors.red.shade700,
              onTap: () async {
                final uri = Uri.parse('tel:122');
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Clipboard.setData(const ClipboardData(text: '122'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تم نسخ الرقم: 122' : 'Copied emergency number: 122')),
                    );
                  }
                } catch (_) {
                  Clipboard.setData(const ClipboardData(text: '122'));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              icon: Icons.share_location_rounded,
              title: isArabic ? 'مشاركة الرحلة عبر واتساب' : 'Share Ride on WhatsApp',
              subtitle: 'Ride #$rideId • $driverName • $plate',
              color: const Color(0xFF25D366),
              onTap: () async {
                final shareText = isArabic
                    ? 'أنا في رحلة مع يلا!\nالكابتن: $driverName\nرقم اللوحة: $plate\nمعرف الرحلة: #$rideId'
                    : 'I am on a Yalla ride!\nDriver: $driverName\nPlate: $plate\nRide ID: #$rideId';
                Clipboard.setData(ClipboardData(text: shareText));
                final waUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
                try {
                  await launchUrl(waUri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isArabic ? 'تم نسخ تفاصيل الرحلة للحافظة' : 'Copied trip info to clipboard')),
                  );
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  void _showDriverCallDialog(String driverName, String driverPhone) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isArabic ? 'الاتصال بالكابتن' : 'Call Captain', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.15),
              child: const Icon(Icons.phone_in_talk, color: AppColors.primaryOrange, size: 30),
            ),
            const SizedBox(height: 16),
            Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(driverPhone, style: const TextStyle(color: Colors.black54, fontSize: 16, letterSpacing: 1)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Close', style: const TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: driverPhone));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'تم نسخ رقم الهاتف: $driverPhone' : 'Copied phone number: $driverPhone')),
              );
            },
            child: Text(isArabic ? 'نسخ الرقم' : 'Copy Number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _markerAnimCtrl?.dispose();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.onDriverMoved = null;
    socketService.onRideStatusUpdate = null;
    socketService.onRideCancelled = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final Map<String, dynamic> ride = _rideData;

    final rideId = (ride['id'] ?? ride['rideId'] ?? '').toString();
    final otpCode = (ride['otp'] ?? '----').toString();

    final dynamic rawDriver = ride['driver'];
    final Map<String, dynamic>? driver = rawDriver is Map<String, dynamic>
        ? rawDriver
        : (rawDriver is Map ? Map<String, dynamic>.from(rawDriver) : null);

    final dynamic rawVehicle = driver?['vehicle'] ?? ride['vehicle'];
    final Map<String, dynamic>? vehicle = rawVehicle is Map<String, dynamic>
        ? rawVehicle
        : (rawVehicle is Map ? Map<String, dynamic>.from(rawVehicle) : null);

    final driverName = ride['driverName'] ??
        (driver != null
            ? "${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}".trim()
            : (isArabic ? 'كابتن الرحلة' : 'Captain'));

    final driverPhone = ride['driverPhone'] ?? driver?['phone'] ?? '07700000000';
    final carModel = ride['carModel'] ??
        (vehicle != null ? "${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}".trim() : 'Toyota Camry');
    final plate = ride['plate'] ??
        (vehicle != null ? "${vehicle['licensePlate'] ?? ''}".trim() : 'Baghdad 12345');
    final driverPhoto = ride['driverPhoto'] ?? driver?['profileImage'];
    final hasDriverPhoto = driverPhoto is String && driverPhoto.isNotEmpty;
    final driverRating = ride['rating'] ?? driver?['rating'] ?? '5.0';
    final vehicleColor = ride['vehicleColor'] ?? vehicle?['color'];

    final double pickupLat = double.tryParse(ride['pickupLat']?.toString() ?? '') ?? 33.3152;
    final double pickupLng = double.tryParse(ride['pickupLng']?.toString() ?? '') ?? 44.3661;
    final double dropLat = double.tryParse(ride['dropLat']?.toString() ?? '') ?? 33.3300;
    final double dropLng = double.tryParse(ride['dropLng']?.toString() ?? '') ?? 44.3800;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map View ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _driverPos, initialZoom: 14.5),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yalla.passenger',
                maxZoom: 19,
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints.isNotEmpty
                        ? _routePoints
                        : [LatLng(pickupLat, pickupLng), _driverPos, LatLng(dropLat, dropLng)],
                    color: AppColors.primaryOrange,
                    strokeWidth: 5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(pickupLat, pickupLng),
                    width: 34,
                    height: 34,
                    child: _pinWidget(Colors.green, Icons.trip_origin),
                  ),
                  Marker(
                    point: _driverPos,
                    width: 52,
                    height: 52,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))],
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: _driverBearing,
                          child: const Icon(Icons.navigation_rounded, color: AppColors.primaryOrange, size: 30),
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: LatLng(dropLat, dropLng),
                    width: 34,
                    height: 34,
                    child: _pinWidget(Colors.red, Icons.location_on),
                  ),
                ],
              ),
            ],
          ),

          // ── Top Status Pill ──
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: FadeInDown(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _statusText,
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (_etaText.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _etaText,
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                      if (_distanceText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(_distanceText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Driver & Actions Card ──
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Security PIN Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'رمز أمان الرحلة (PIN)' : 'Start Trip PIN',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                ),
                                Text(
                                  isArabic ? 'أعطِ هذا الرمز للكابتن عند الصعود' : 'Share this code with captain upon arrival',
                                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              otpCode,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Driver Information Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryOrange.withOpacity(0.15),
                          backgroundImage: hasDriverPhoto
                              ? NetworkImage(driverPhoto)
                              : null,
                          child: hasDriverPhoto
                              ? null
                              : const Icon(Icons.person, color: AppColors.primaryOrange, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(
                                [carModel, vehicleColor, '★ $driverRating'].where((value) => value != null && value.toString().isNotEmpty).join(' · '),
                                style: GoogleFonts.inter(color: Colors.black54, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withOpacity(0.06)),
                          ),
                          child: Text(
                            plate,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Actions Row: Chat, Call, Safety, Cancel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionCircle(
                          Icons.chat_bubble_rounded,
                          isArabic ? 'مراسلة' : 'Chat',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PassengerChatScreen(
                                  rideId: rideId,
                                  driverName: driverName,
                                  driverPhone: driverPhone,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildActionCircle(
                          Icons.call_rounded,
                          isArabic ? 'اتصال' : 'Call',
                          onTap: () => _showDriverCallDialog(driverName, driverPhone),
                        ),
                        _buildActionCircle(
                          Icons.shield_rounded,
                          isArabic ? 'أمان' : 'Safety',
                          color: Colors.blue.shade700,
                          onTap: () => _showSafetySheet(rideId, driverName, plate),
                        ),
                        _buildActionCircle(
                          Icons.cancel_outlined,
                          isArabic ? 'إلغاء' : 'Cancel',
                          color: Colors.red,
                          onTap: () => _showCancelDialog(rideId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinWidget(Color color, IconData icon) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: color, size: 20),
      );

  Widget _buildActionCircle(
    IconData icon,
    String label, {
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.inter(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
