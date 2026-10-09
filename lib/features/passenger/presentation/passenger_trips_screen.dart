import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'trip_information_screen.dart';

class PassengerTripsScreen extends StatefulWidget {
  const PassengerTripsScreen({super.key});

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
                        onPressed: () => Navigator.pop(context),
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
      return '${dt.day} ${months[dt.month - 1]}  $h:$min $amPm';
    } catch (_) { return iso.toString(); }
  }

  String _fmtPrice(dynamic val, bool isArabic) {
    final n = double.tryParse(val?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0;
    if (n == 0) return isArabic ? '--' : '--';
    final s = n.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$s ${isArabic ? "د.ع" : "IQD"}';
  }

  Widget _buildRideCard(dynamic ride) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final dynamic rawDriver = ride is Map ? ride['driver'] : null;
    final driverName = rawDriver is Map
        ? '${rawDriver['firstName'] ?? ''} ${rawDriver['lastName'] ?? ''}'.trim()
        : (ride is Map ? ride['driverName'] : null) ?? (isArabic ? 'كابتن الرحلة' : 'Captain');
    final driverRating = rawDriver is Map ? (rawDriver['rating'] ?? 5.0) : 5.0;
    final priceVal = ride is Map ? (ride['finalPrice'] ?? ride['estimatedPrice'] ?? ride['price']) : null;
    final price = _fmtPrice(priceVal, isArabic);
    final date = _fmtDate(ride is Map ? (ride['requestedAt'] ?? ride['createdAt']) : null);
    final from = (ride is Map ? (ride['pickupName'] ?? ride['originName']) : null) ?? (isArabic ? 'موقع الانطلاق' : 'Pickup');
    final to = (ride is Map ? (ride['dropName'] ?? ride['destinationName']) : null) ?? (isArabic ? 'الوجهة' : 'Destination');
    final pLat = double.tryParse((ride is Map ? ride['pickupLat'] : null)?.toString() ?? '') ?? 35.46;
    final pLng = double.tryParse((ride is Map ? ride['pickupLng'] : null)?.toString() ?? '') ?? 44.38;
    final dLat = double.tryParse((ride is Map ? ride['dropLat'] : null)?.toString() ?? '') ?? 36.19;
    final dLng = double.tryParse((ride is Map ? ride['dropLng'] : null)?.toString() ?? '') ?? 44.00;
    final stars = (driverRating is num) ? driverRating.toDouble().clamp(1.0, 5.0) : 5.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripInformationScreen(rideData: ride)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ],
        ),
      child: Column(
        children: [
          // Map preview
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(35.5, 44.4), // Kirkuk/Erbil area
                  initialZoom: 7,
                  interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.iqalmassar.passenger',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(pLat, pLng),
                      width: 20, height: 20,
                      child: _mapDot(Colors.blue),
                    ),
                    Marker(
                      point: LatLng(dLat, dLng),
                      width: 20, height: 20,
                      child: _mapDot(Colors.red),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFF0F0F0),
                              child: Text(
                                driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              driverName.isEmpty ? (isArabic ? 'كابتن' : 'Captain') : driverName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < stars.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 15,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(price, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryOrange)),
                        Text(date, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                      ],
                    ),
                const SizedBox(height: 12),
                const Divider(color: Colors.black12, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(from, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(to, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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

  Widget _mapPin(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Icon(Icons.location_on, color: color, size: 18),
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
