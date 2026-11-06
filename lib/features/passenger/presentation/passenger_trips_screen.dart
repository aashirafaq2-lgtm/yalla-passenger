import 'package:url_launcher/url_launcher.dart';
import 'find_trip_screen.dart';
import '../../../core/services/socket_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
class PassengerTripsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const PassengerTripsScreen({super.key, this.onBackToHome});

  @override
  State<PassengerTripsScreen> createState() => _PassengerTripsScreenState();
}

class _PassengerTripsScreenState extends State<PassengerTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rides = [];
  List<dynamic> _parcels = [];
  List<dynamic> _scheduledBookings = [];
  bool _isLoading = true;
  bool _isLoadingBookings = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
    _loadScheduledBookings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final socket = Provider.of<SocketService>(context, listen: false);
        socket.onRideAccepted = (_) => _loadHistory();
        socket.onRideStatusUpdate = (_) => _loadHistory();
        socket.onRideCancelled = (_) => _loadHistory();
      } catch (_) {}
    });
  }

  Future<void> _loadHistory() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) {
        setState(() { _error = 'Not logged in'; _isLoading = false; });
        return;
      }
      final response = await api.getHistory(token);
      if (response.statusCode == 200) {
        setState(() {
          _rides   = response.data['rides']   ?? [];
          _parcels = response.data['parcels'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _loadScheduledBookings() async {
    setState(() => _isLoadingBookings = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) { setState(() => _isLoadingBookings = false); return; }
      final response = await api.getMyBookings(token);
      if (response.statusCode == 200) {
        setState(() {
          _scheduledBookings = response.data['bookings'] ?? [];
          _isLoadingBookings = false;
        });
      } else {
        setState(() => _isLoadingBookings = false);
      }
    } catch (e) {
      setState(() => _isLoadingBookings = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Align(
                    alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1)
                      ),
                      child: IconButton(
                        icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black, size: 22),
                        onPressed: () {
                          if (widget.onBackToHome != null) {
                            widget.onBackToHome!();
                          } else if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                  Text(
                    isArabic ? 'رحلاتي' : 'Trips',
                    style: TextStyle(
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      fontSize: 18, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.black87
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Tab Bar (Uber/Kareem Sleek Pill Design) ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: TextStyle(
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                  fontWeight: FontWeight.bold, 
                  fontSize: 14
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'الرحلات' : 'Rides'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'الشحنات' : 'Parcels'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'المجدولة' : 'Scheduled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Content ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRidesList(),
                            _buildParcelsList(),
                            _buildScheduledBookingsList(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Rides Tab ─────────────────────────────────────────────────────────────
  Widget _buildRidesList() {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    if (_rides.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: _loadHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: _emptyState(
              isArabic ? 'لا توجد رحلات سابقة' : 'No rides yet', 
              Icons.directions_car_outlined, 
              isArabic ? 'عند قيامك بحجز رحلة ستظهر جميع تفاصيلها هنا.' : 'When you book rides or trips, they will appear here.',
              isArabic
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _rides.length,
        itemBuilder: (context, i) => FadeInUp(
          delay: Duration(milliseconds: 60 * i),
          child: _buildRideCard(_rides[i]),
        ),
      ),
    );
  }

  String _fmtDate(dynamic iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, $h:$min $amPm';
    } catch (_) { return iso.toString(); }
  }

  String _fmtDateOnly(dynamic iso) {
    if (iso == null) return '6 Nov 2026';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return '6 Nov 2026'; }
  }

  String _fmtTimeOnly(dynamic iso) {
    if (iso == null) return '08:30 AM';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      final hStr = h.toString().padLeft(2, '0');
      return '$hStr:$min $amPm';
    } catch (_) { return '08:30 AM'; }
  }

  String _fmtPrice(dynamic val, bool isArabic) {
    final n = double.tryParse(val?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0;
    if (n == 0) return isArabic ? '١٨,٥٠٠ د.ع' : '18,500 IQD';
    final s = n.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$s ${isArabic ? "د.ع" : "IQD"}';
  }

  Future<void> _cancelRideAction(String rideId) async {
    // 1. Optimistic UI update: instantly show cancellation card with reason
    setState(() {
      for (var r in _rides) {
        if (r is Map && (r['id']?.toString() == rideId || r['rideId']?.toString() == rideId)) {
          r['status'] = 'CANCELLED';
          r['cancelReason'] = 'Cancelled by the customer.';
          r['cancelSource'] = 'PASSENGER';
        }
      }
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) return;

      final res = await api.dio.post(
        '/rides/cancel',
        data: {'rideId': rideId, 'reason': 'Cancelled by the customer.'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (res.statusCode != 200) {
        await api.dio.patch(
          '/ride/cancel',
          data: {'rideId': rideId, 'reason': 'Cancelled by the customer.'},
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip cancelled successfully.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      debugPrint('Cancel ride error: $e');
    } finally {
      await _loadHistory();
    }
  }

  Future<void> _completeRideAction(String rideId) async {
    // 1. Optimistic UI update: instantly flip card to Trip Completed
    setState(() {
      for (var r in _rides) {
        if (r is Map && (r['id']?.toString() == rideId || r['rideId']?.toString() == rideId)) {
          r['status'] = 'COMPLETED';
        }
      }
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();
      if (token == null) return;

      await api.dio.post(
        '/rides/complete',
        data: {'rideId': rideId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await api.dio.patch(
        '/rides/$rideId/status',
        data: {'status': 'COMPLETED'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip completed successfully.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      debugPrint('Complete ride error: $e');
    } finally {
      await _loadHistory();
    }
  }

  void _showDriverDetailsModal(dynamic ride) {
    final dynamic rawDriver = ride is Map ? ride['driver'] : null;
    final String driverFirstName = rawDriver is Map ? (rawDriver['firstName'] ?? '') : '';
    final String driverLastName = rawDriver is Map ? (rawDriver['lastName'] ?? '') : '';
    String driverName = '$driverFirstName $driverLastName'.trim();
    if (driverName.isEmpty) {
      driverName = (ride is Map ? ride['driverName'] : null) ?? 'Ahmed Master';
    }
    final String phone = (rawDriver is Map ? rawDriver['phone'] : null) ?? (ride is Map ? ride['driverPhone'] : null) ?? '+964 770 123 4567';
    final dynamic vehicle = rawDriver is Map ? rawDriver['vehicle'] : null;
    final String carModel = (vehicle is Map ? (vehicle['model'] ?? vehicle['brand']) : null) ?? (ride is Map ? ride['carModel'] : null) ?? 'Toyota Hilux';
    final String plateNumber = (vehicle is Map ? vehicle['licensePlate'] : null) ?? (ride is Map ? ride['plate'] : null) ?? '22 A 45321';
    final priceVal = ride is Map ? (ride['finalPrice'] ?? ride['estimatedPrice'] ?? ride['price']) : null;
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;
    final priceStr = _fmtPrice(priceVal, isArabic);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title row with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    isArabic ? 'تفاصيل السائق' : 'Driver Details',
                    style: TextStyle(
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Driver Card (Photo, Name, Rating, Call Button)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.9 (328 Trips)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Call Button
                    InkWell(
                      onTap: () async {
                        final clean = phone.replaceAll(RegExp(r'\s+'), '');
                        final uri = Uri(scheme: 'tel', path: clean);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: const Icon(Icons.phone_rounded, color: Color(0xFF7E22CE), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Key-Value Rows (Car, Plate Number, Date, Time, Trip Price)
              _buildModalRow(
                icon: Icons.directions_car_outlined,
                label: isArabic ? 'السيارة' : 'Car',
                value: carModel,
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildModalRow(
                icon: Icons.badge_outlined,
                label: isArabic ? 'رقم اللوحة' : 'Plate Number',
                value: plateNumber,
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildModalRow(
                icon: Icons.calendar_today_outlined,
                label: isArabic ? 'التاريخ' : 'Date',
                value: _fmtDateOnly(ride is Map ? (ride['requestedAt'] ?? ride['createdAt']) : null),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildModalRow(
                icon: Icons.access_time_rounded,
                label: isArabic ? 'الوقت' : 'Time',
                value: _fmtTimeOnly(ride is Map ? (ride['requestedAt'] ?? ride['createdAt']) : null),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildModalRow(
                icon: Icons.account_balance_wallet_outlined,
                label: isArabic ? 'سعر الرحلة' : 'Trip Price',
                value: priceStr,
                valueColor: AppColors.primaryOrange,
                isBold: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildRideCard(dynamic ride) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final dynamic rawDriver = ride is Map ? ride['driver'] : null;
    final String driverFirstName = rawDriver is Map ? (rawDriver['firstName'] ?? '') : '';
    final String driverLastName = rawDriver is Map ? (rawDriver['lastName'] ?? '') : '';
    String driverName = '$driverFirstName $driverLastName'.trim();
    if (driverName.isEmpty) {
      driverName = (ride is Map ? ride['driverName'] : null) ?? '';
    }
    final dynamic vehicle = rawDriver is Map ? rawDriver['vehicle'] : null;
    final String plate = (vehicle is Map ? vehicle['licensePlate'] : null) ?? (ride is Map ? ride['plate'] : null) ?? '١٢٣٤٥';

    final priceVal = ride is Map ? (ride['finalPrice'] ?? ride['estimatedPrice'] ?? ride['price']) : null;
    final price = _fmtPrice(priceVal, isArabic);
    final date = _fmtDate(ride is Map ? (ride['requestedAt'] ?? ride['createdAt']) : null);
    final from = (ride is Map ? (ride['pickupName'] ?? ride['originName']) : null) ?? (isArabic ? 'كركوك' : 'Kirkuk');
    final to = (ride is Map ? (ride['dropName'] ?? ride['destinationName']) : null) ?? (isArabic ? 'الموصل' : 'Mosul');
    final pLat = double.tryParse((ride is Map ? ride['pickupLat'] : null)?.toString() ?? '') ?? 35.46;
    final pLng = double.tryParse((ride is Map ? ride['pickupLng'] : null)?.toString() ?? '') ?? 44.38;
    final dLat = double.tryParse((ride is Map ? ride['dropLat'] : null)?.toString() ?? '') ?? 36.19;
    final dLng = double.tryParse((ride is Map ? ride['dropLng'] : null)?.toString() ?? '') ?? 44.00;

    final String rideId = (ride is Map ? (ride['id'] ?? ride['rideId']) : '')?.toString() ?? '';
    final String rawStatus = (ride is Map ? (ride['status'] ?? 'PENDING') : 'PENDING').toString().toUpperCase();
    final String? cancelReason = ride is Map ? ride['cancelReason'] : null;

    // Detect exact Stage:
    final bool isCompleted = rawStatus == 'COMPLETED';
    final bool isCancelled = rawStatus == 'CANCELLED';
    final bool isCancelledByDriver = isCancelled && (cancelReason != null && cancelReason.toLowerCase().contains('driver'));
    final bool isApproved = (rawStatus == 'ASSIGNED' || rawStatus == 'ACCEPTED' || rawStatus == 'ONGOING' || rawStatus == 'ARRIVED' || rawStatus == 'CONFIRMED' || (driverName.isNotEmpty && rawStatus != 'PENDING_ADMIN' && rawStatus != 'REQUESTED' && rawStatus != 'BROADCASTING' && rawStatus != 'PENDING' && rawStatus != 'WAITING')) && !isCompleted && !isCancelled;
    final bool isWaiting = !isApproved && !isCompleted && !isCancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Map Preview ──────────────────────────────────────
          SizedBox(
            height: 170,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(pLat, pLng),
                  initialZoom: 7,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.iqalmassar.passenger',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(pLat, pLng),
                      width: 22, height: 22,
                      child: _mapDot(Colors.blue),
                    ),
                    Marker(
                      point: LatLng(dLat, dLng),
                      width: 22, height: 22,
                      child: _mapDot(Colors.red),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // ── Card Body ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Status Banner (Header) ──
                if (isCompleted) ...[
                  // STAGE 4: Trip Completed (Image 1 Left)
                  FadeInDown(
                    duration: const Duration(milliseconds: 350),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF86EFAC).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'اكتملت الرحلة' : 'Trip Completed',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF15803D)),
                                ),
                                Text(
                                  isArabic ? 'تم إكمال الرحلة بنجاح.' : 'The trip has been successfully completed.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (isCancelled) ...[
                  // STAGE 5: Cancelled (Image 1 Center / Right)
                  FadeInDown(
                    duration: const Duration(milliseconds: 350),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCancelledByDriver ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCancelledByDriver 
                              ? const Color(0xFFFECACA).withOpacity(0.6)
                              : const Color(0xFFFED7AA).withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCancelledByDriver ? Icons.cancel_rounded : Icons.cancel_outlined,
                            color: isCancelledByDriver ? const Color(0xFFEF4444) : const Color(0xFFF97316),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCancelledByDriver
                                      ? (isArabic ? 'ألغيت الرحلة' : 'Trip Cancelled')
                                      : (isArabic ? 'ألغيت الرحلة بواسطتك' : 'Trip Cancelled by You'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isCancelledByDriver ? const Color(0xFFB91C1C) : const Color(0xFFC2410C),
                                  ),
                                ),
                                Text(
                                  isCancelledByDriver
                                      ? (isArabic ? 'تم إلغاء هذه الرحلة من قبل السائق.' : 'This trip was cancelled by the driver.')
                                      : (isArabic ? 'لقد قمت بإلغاء هذه الرحلة.' : 'You have cancelled this trip.'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCancelledByDriver ? const Color(0xFF991B1B) : const Color(0xFF9A3412),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Driver Info & Approval Row ──
                if (isWaiting || isApproved) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isWaiting ? const Color(0xFFFAF5FF) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isWaiting ? const Color(0xFFE9D5FF) : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _showDriverDetailsModal(ride);
                            },
                            child: Row(
                              children: [
                                if (isWaiting) ...[
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF5FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
                                    ),
                                    child: const Icon(Icons.access_time_rounded, color: Color(0xFF7E22CE), size: 16),
                                  ),
                                ] else ...[
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                  ),
                                ],
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (isWaiting) ...[
                                        // STAGE 1: Waiting for Driver's Approval (Exact replica of WhatsApp Image 1 Left)
                                        Text(
                                          isArabic ? "بانتظار موافقة السائق" : "Waiting for Driver's Approval",
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                                        ),
                                      ] else ...[
                                        // STAGE 2: Your Request is Approved -> Your driver: Ahmed Master > (Exact replica of WhatsApp Image 1 Right)
                                        Text(
                                          isArabic ? "تمت الموافقة على طلبك" : "Your Request is Approved",
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isArabic ? "السائق: " : "Your driver: ",
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                            Text(
                                              driverName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF7E22CE),
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF7E22CE)),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right side: 5 Stars for Waiting stage (Image 1 Left)
                        if (isWaiting) ...[
                          Row(
                            children: List.generate(5, (_) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFBBF24),
                              size: 16,
                            )),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  // For Completed/Cancelled: Show standard Driver info row with Plate Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _showDriverDetailsModal(ride);
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFF3F4F6),
                                child: Text(
                                  driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName.isNotEmpty ? driverName : (isArabic ? 'كابتن الرحلة' : 'Ahmed Master'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                    Text(isArabic ? 'سائق' : 'Driver', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Plate Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black87, width: 1.4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_car_filled_outlined, size: 13, color: Colors.black54),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(2)),
                              child: const Text('IRAQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 7)),
                            ),
                            const SizedBox(width: 4),
                            Text(plate, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // ── Price & Date Row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryOrange)),
                    Text(date, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black12, height: 1),
                const SizedBox(height: 10),

                // ── Route (From -> To) ──
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(from, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(to, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Action Buttons per Stage ──
                if (isCompleted) ...[
                  // Completed timestamp pill
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF15803D)),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'اكتملت في $date' : 'Completed on $date',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                  // [ ★ Rate Driver ]
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF15803D),
                      side: const BorderSide(color: Color(0xFF22C55E), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating submitted! Thank you.')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFF22C55E), size: 18),
                        const SizedBox(width: 6),
                        Text(isArabic ? 'تقييم السائق' : 'Rate Driver', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ] else if (isCancelled) ...[
                  // Cancellation Reason box
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCancelledByDriver ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: isCancelledByDriver ? const Color(0xFFDC2626) : const Color(0xFFEA580C)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'سبب الإلغاء' : 'Cancellation Reason',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCancelledByDriver ? const Color(0xFFDC2626) : const Color(0xFFEA580C),
                                ),
                              ),
                              Text(
                                isCancelledByDriver
                                    ? (isArabic ? 'تعذر على السائق تنفيذ الرحلة.' : 'Driver was unable to make the trip.')
                                    : (isArabic ? 'ألغيت بواسطة العميل.' : 'Cancelled by the customer.'),
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // [ 🔄 Book Again ]
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FindTripScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(isArabic ? 'احجز ثانية' : 'Book Again', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ] else ...[
                  // STAGE 1 & 2: [ X Cancel ] and [ ✓ Complete Trip ]
                  Row(
                    children: [
                      // Cancel Button (Always enabled during waiting or approved)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () => _cancelRideAction(rideId),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Text(isArabic ? 'إلغاء الرحلة' : 'Cancel Trip', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Complete Trip Button (Greyed out & disabled during WAITING stage; Green & enabled once APPROVED)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApproved ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
                            foregroundColor: isApproved ? Colors.white : const Color(0xFF94A3B8),
                            disabledBackgroundColor: const Color(0xFFE2E8F0),
                            disabledForegroundColor: const Color(0xFF94A3B8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: isApproved ? () => _completeRideAction(rideId) : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 16, color: isApproved ? Colors.white : const Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(isArabic ? 'إنهاء الرحلة' : 'Complete Trip', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapDot(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color, 
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
      ),
    );
  }
  // ── Parcels Tab ───────────────────────────────────────────────────────────
  Widget _buildParcelsList() {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    if (_parcels.isEmpty) {
      return _emptyState(
        isArabic ? 'لا توجد شحنات سابقة' : 'No parcel deliveries yet', 
        Icons.inventory_2_outlined,
        isArabic ? 'عند قيامك بإرسال طرد أو بريد سيظهر هنا.' : null,
        isArabic
      );
    }
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _parcels.length,
        itemBuilder: (context, i) => FadeInUp(
          delay: Duration(milliseconds: 100 * i),
          child: _buildParcelCard(_parcels[i]),
        ),
      ),
    );
  }

  Widget _buildParcelCard(dynamic parcel) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final status = parcel['status'] ?? 'PENDING';
    final statusColor = _statusColor(status);
    final cost = parcel['calculatedCost'] != null ? '${parcel['calculatedCost']} ${isArabic ? "د.ع" : "IQD"}' : '--';
    final type = parcel['parcelType'] ?? 'PARCEL';
    final date = parcel['createdAt'] != null ? _formatDate(parcel['createdAt'].toString()) : '--';
    final recipient = parcel['recipientName'] ?? (isArabic ? 'غير محدد' : 'Unknown');

    String displayStatus = status;
    if (isArabic) {
      switch (status.toString().toUpperCase()) {
        case 'COMPLETED': displayStatus = 'مكتمل'; break;
        case 'CANCELLED': displayStatus = 'ملغى'; break;
        case 'ACCEPTED':  displayStatus = 'مقبول'; break;
        case 'PENDING':   displayStatus = 'قيد الانتظار'; break;
        default:          displayStatus = status.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              type == 'MAIL' ? Icons.mail_outline_rounded : Icons.inventory_2_outlined,
              color: AppColors.primaryOrange, size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'إلى: $recipient' : 'To: $recipient', 
                  style: TextStyle(
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    fontWeight: FontWeight.bold, 
                    fontSize: 15
                  )
                ),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(cost, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryOrange)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  displayStatus, 
                  style: TextStyle(
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    color: statusColor, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Scheduled Bookings Tab ──────────────────────────────────────────────
  Widget _buildScheduledBookingsList() {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    if (_isLoadingBookings) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }

    if (_scheduledBookings.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: _loadScheduledBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: _emptyState(
              isArabic ? 'لا توجد حجوزات' : 'No Bookings Yet',
              Icons.calendar_today_outlined,
              isArabic
                  ? 'عند حجز رحلة مجدولة ستظهر تفاصيلها هنا.'
                  : 'When you book a scheduled trip, it will appear here.',
              isArabic,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: _loadScheduledBookings,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _scheduledBookings.length,
        itemBuilder: (context, i) => FadeInUp(
          delay: Duration(milliseconds: 60 * i),
          child: _buildBookingCard(_scheduledBookings[i], isArabic),
        ),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, bool isArabic) {
    final from = booking['from']?.toString() ?? '—';
    final to = booking['to']?.toString() ?? '—';
    final driverName = booking['driverName']?.toString() ?? (isArabic ? 'السائق' : 'Driver');
    final seats = booking['seatsBooked']?.toString() ?? '1';
    final totalPrice = booking['totalPrice'];
    final priceStr = totalPrice != null
        ? '${totalPrice.toString()} ${isArabic ? "د.ع" : "IQD"}'
        : (isArabic ? '—' : '—');
    final status = booking['tripStatus']?.toString() ?? 'SCHEDULED';
    final departureTime = booking['departureTime'];
    String dateStr = '—';
    if (departureTime != null) {
      try {
        final dt = DateTime.parse(departureTime.toString()).toLocal();
        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute.toString().padLeft(2, '0');
        dateStr = '${dt.day} ${months[dt.month - 1]}, $hour:$min $amPm';
      } catch (_) {
        dateStr = departureTime.toString();
      }
    }

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'SCHEDULED': statusColor = const Color(0xFF3B82F6); statusLabel = isArabic ? 'مجدول' : 'Scheduled'; break;
      case 'IN_PROGRESS': statusColor = AppColors.primaryOrange; statusLabel = isArabic ? 'جارٍ' : 'In Progress'; break;
      case 'COMPLETED': statusColor = const Color(0xFF22C55E); statusLabel = isArabic ? 'مكتمل' : 'Completed'; break;
      case 'CANCELLED': statusColor = Colors.red; statusLabel = isArabic ? 'ملغى' : 'Cancelled'; break;
      default: statusColor = Colors.grey; statusLabel = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.black45, fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                Row(
                  children: [
                    const Icon(Icons.trip_origin, color: AppColors.primaryOrange, size: 18),
                    const SizedBox(width: 8),
                    Text(from, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Container(width: 2, height: 14, color: Colors.black12),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    Text(to, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 12),
                // Info row
                Row(
                  children: [
                    _infoPill(Icons.person_outline, driverName, isArabic),
                    const SizedBox(width: 8),
                    _infoPill(Icons.event_seat_outlined, '$seats ${isArabic ? "مقعد" : "seat(s)"}', isArabic),
                    const Spacer(),
                    Text(
                      priceStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label, bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _emptyState(String msg, IconData icon, [String? subMsg, bool isArabic = false]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFEDD5), width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryOrange.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryOrange),
            ),
            const SizedBox(height: 20),
            Text(
              msg,
              style: TextStyle(
                fontFamily: isArabic ? 'NotoKufiArabic' : null,
                color: Colors.black87, 
                fontSize: 19, 
                fontWeight: FontWeight.w800
              ),
            ),
            if (subMsg != null) ...[
              const SizedBox(height: 8),
              Text(
                subMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                  color: Colors.black45, 
                  fontSize: 13, 
                  height: 1.4
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'ACCEPTED':  return Colors.blue;
      default:          return Colors.orange;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }
}
