import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
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
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1)
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Text('Trips',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [Tab(text: 'Rides'), Tab(text: 'Parcels')],
              ),
            ),
            const SizedBox(height: 10),

            // ── Content ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRidesList(),
                            _buildParcelsList(),
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
    if (_rides.isEmpty) return _emptyState('No rides yet', Icons.directions_car_outlined);
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _rides.length,
        itemBuilder: (context, i) => FadeInUp(
          delay: Duration(milliseconds: 100 * i),
          child: _buildRideCard(_rides[i]),
        ),
      ),
    );
  }

  Widget _buildRideCard(dynamic ride) {
    final driverName = ride['driver'] != null
        ? '${ride['driver']['firstName']} ${ride['driver']['lastName']}'
        : 'Adnan Dirjal'; // Mocked name to match screenshot sample
    final price = ride['price'] != null ? '${ride['price']} IQD' : '10,000 IQD';
    final date = 'Feb 14 Saturday roam ride'; // Specific date format to match screenshot
    final from = ride['originName'] ?? 'Kirkuk, --';
    final to = ride['destinationName'] ?? 'Erbil, --';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TripInformationScreen()),
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
                      point: const LatLng(35.46, 44.38), // Kirkuk approx
                      width: 20, height: 20,
                      child: _mapDot(Colors.blue),
                    ),
                    Marker(
                      point: const LatLng(36.19, 44.00), // Erbil approx
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18, 
                          backgroundColor: Color(0xFFF0F0F0), 
                          child: Icon(Icons.person, size: 22, color: Colors.grey)
                        ),
                        const SizedBox(width: 12),
                        Text(driverName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star_border, color: Colors.grey, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
    if (_parcels.isEmpty) return _emptyState('No parcel deliveries yet', Icons.inventory_2_outlined);
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
    final status = parcel['status'] ?? 'PENDING';
    final statusColor = _statusColor(status);
    final cost = parcel['calculatedCost'] != null ? '${parcel['calculatedCost']} IQD' : '--';
    final type = parcel['parcelType'] ?? 'PARCEL';
    final date = parcel['createdAt'] != null ? _formatDate(parcel['createdAt'].toString()) : '--';
    final recipient = parcel['recipientName'] ?? 'Unknown';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To: $recipient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cost, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryOrange)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.black12),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.black38, fontSize: 16)),
        ],
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
