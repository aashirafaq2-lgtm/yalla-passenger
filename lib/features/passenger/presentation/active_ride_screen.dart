import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_chat_screen.dart';
import 'trip_summary_screen.dart';

class ActiveRideScreen extends StatefulWidget {
  final dynamic rideData;
  const ActiveRideScreen({super.key, this.rideData});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  LatLng _driverPos = const LatLng(33.3200, 44.3710);
  final MapController _mapController = MapController();
  String _statusText = 'Driver is on the way';
  bool _isCompletedNavigated = false;

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    final dynamic raw = widget.rideData;
    final rideId = (raw is Map ? (raw['id'] ?? raw['rideId']) : null)?.toString();
    if (rideId != null && rideId.isNotEmpty) {
      socketService.joinRide(rideId);
    }
    _listenToSocketEvents();
  }

  void _listenToSocketEvents() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    // Live driver moving coordinates
    socketService.onDriverMoved = (data) {
      if (!mounted) return;
      if (data is Map && data['lat'] != null && data['lng'] != null) {
        setState(() {
          _driverPos = LatLng(
            (data['lat'] as num).toDouble(),
            (data['lng'] as num).toDouble(),
          );
        });
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
        } else if (status == 'PICKED_UP' || status == 'ONGOING') {
          _statusText = isArabic ? 'الرحلة قيد التنفيذ' : 'Trip in progress';
        } else if (status == 'COMPLETED') {
          _statusText = isArabic ? 'اكتملت الرحلة بنجاح!' : 'Trip Completed';
        }
      });

      if (status == 'COMPLETED' && !_isCompletedNavigated) {
        _isCompletedNavigated = true;
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
        _showCancelledNotice(data['reason']?.toString() ?? 'Ride was cancelled by driver');
      }
    };

    socketService.onRideCancelled = (data) {
      if (!mounted) return;
      _showCancelledNotice(data['reason']?.toString() ?? 'Ride was cancelled');
    };
  }

  void _showCancelledNotice(String reason) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(locale.isArabic ? 'تم إلغاء الرحلة' : 'Ride Cancelled',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          locale.isArabic
              ? 'نعتذر، تم إلغاء طلب الرحلة.\nالسبب: $reason'
              : 'The ride was cancelled.\nReason: $reason',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: Text(
              locale.isArabic ? 'العودة للرئيسية' : 'Return Home',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
        builder: (context, setSheetState) => Container(
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

                        if (token != null) {
                          try {
                            await api.cancelRide(rideId, selectedReason, token);
                          } catch (e) {
                            debugPrint('Cancel ride note: $e');
                          }
                        }

                        if (mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
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
                  isArabic ? 'مركز الأمان والسلامة' : 'Safety & Emergency Toolkit',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'خطوط الطوارئ المعتمدة في جمهورية العراق:'
                  : 'Emergency hotlines in the Republic of Iraq:',
              style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildEmergencyTile(
              icon: Icons.local_police_rounded,
              title: isArabic ? 'شرطة النجدة (104)' : 'Police Hotline (104)',
              subtitle: isArabic ? 'اتصال فوري بالشرطة' : 'Direct emergency police line',
              color: Colors.blue.shade800,
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '104'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isArabic ? 'تم نسخ الرقم: 104' : 'Copied emergency number: 104')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              icon: Icons.medical_services_rounded,
              title: isArabic ? 'الإسعاف الفوري (122)' : 'Medical Ambulance (122)',
              subtitle: isArabic ? 'طوارئ الإسعاف الطبي' : 'Immediate medical rescue',
              color: Colors.red.shade700,
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '122'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isArabic ? 'تم نسخ الرقم: 122' : 'Copied emergency number: 122')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              icon: Icons.share_location_rounded,
              title: isArabic ? 'مشاركة تفاصيل الرحلة' : 'Share Trip Details',
              subtitle: 'Ride #$rideId • $driverName • $plate',
              color: AppColors.primaryOrange,
              onTap: () {
                final tripSummary = 'Yalla Ride tracking: Captain $driverName, Plate: $plate, Ride ID: $rideId';
                Clipboard.setData(ClipboardData(text: tripSummary));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isArabic ? 'تم نسخ تفاصيل الرحلة للحافظة' : 'Copied trip info to clipboard')),
                );
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

    final dynamic rawRide = widget.rideData;
    final Map<String, dynamic> ride = rawRide is Map<String, dynamic>
        ? rawRide
        : (rawRide is Map ? Map<String, dynamic>.from(rawRide) : <String, dynamic>{});

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

    final pickupLat = (ride['pickupLat'] as num?)?.toDouble() ?? 33.3152;
    final pickupLng = (ride['pickupLng'] as num?)?.toDouble() ?? 44.3661;
    final dropLat = (ride['dropLat'] as num?)?.toDouble() ?? 33.3300;
    final dropLng = (ride['dropLng'] as num?)?.toDouble() ?? 44.3800;

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
                    points: [LatLng(pickupLat, pickupLng), _driverPos, LatLng(dropLat, dropLng)],
                    color: AppColors.primaryOrange,
                    strokeWidth: 4,
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
                      child: const Center(
                        child: Icon(Icons.directions_car, color: AppColors.primaryOrange, size: 30),
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
                          child: const Icon(Icons.person, color: AppColors.primaryOrange, size: 30),
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
                                carModel,
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
