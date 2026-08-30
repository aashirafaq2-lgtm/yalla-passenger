import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';

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
  bool _isRated = false;

  @override
  void initState() {
    super.initState();
    _listenToDriverLocation();
  }

  void _listenToDriverLocation() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.onDriverMoved = (data) {
      if (!mounted) return;
      setState(() {
        _driverPos = LatLng(
          (data['lat'] as num).toDouble(),
          (data['lng'] as num).toDouble(),
        );
        _statusText = data['status'] ?? 'Driver is on the way';
      });
      _mapController.move(_driverPos, 14.5);

      if (_statusText.contains('Completed') && !_isRated) {
        _isRated = true;
        _showRatingDialog();
      }
    };
  }

  void _showRatingDialog() {
    int selectedStars = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text('Rate Your Trip', style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your ride with the driver?', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < selectedStars ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                  onPressed: () => setDialogState(() => selectedStars = index + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  final api = Provider.of<ApiService>(context, listen: false);
                  final storage = Provider.of<StorageService>(context, listen: false);
                  final token = await storage.getToken();
                  
                  await api.submitReview(
                    widget.rideData['id'] ?? widget.rideData['rideId'],
                    selectedStars,
                    commentController.text,
                    token!
                  );
                  
                  if (mounted) {
                    Navigator.pop(context); // close dialog
                    Navigator.of(context).popUntil((r) => r.isFirst); // back to home
                  }
                },
                child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.onDriverMoved = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Data from rideData (can be nested from backend or flat from socket)
    final ride = widget.rideData;
    final driver = ride['driver'];
    final vehicle = driver?['vehicle'];

    final driverName = ride['driverName'] ?? (driver != null ? "${driver['firstName']} ${driver['lastName']}" : 'Your Driver');
    final carModel   = ride['carModel']   ?? (vehicle != null ? "${vehicle['model']}" : '--');
    final plate      = ride['plate']      ?? (vehicle != null ? "${vehicle['licensePlate']}" : '---');

    final pickupLat  = (ride['pickupLat']  as num?)?.toDouble() ?? 33.3152;
    final pickupLng  = (ride['pickupLng']  as num?)?.toDouble() ?? 44.3661;
    final dropLat    = (ride['dropLat']    as num?)?.toDouble() ?? 33.3300;
    final dropLng    = (ride['dropLng']    as num?)?.toDouble() ?? 44.3800;

    return Scaffold(
      body: Stack(
        children: [
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
                  Polyline(points: [LatLng(pickupLat, pickupLng), _driverPos, LatLng(dropLat, dropLng)], color: AppColors.primaryOrange, strokeWidth: 4),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(point: LatLng(pickupLat, pickupLng), width: 34, height: 34, child: _pinWidget(Colors.green, Icons.trip_origin)),
                  Marker(
                    point: _driverPos,
                    width: 50, height: 50,
                    child: Pulse(
                      infinite: true,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                        child: const Icon(Icons.directions_car, color: AppColors.primaryOrange, size: 28),
                      ),
                    ),
                  ),
                  Marker(point: LatLng(dropLat, dropLng), width: 34, height: 34, child: _pinWidget(Colors.red, Icons.location_on)),
                ],
              ),
            ],
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: FadeInDown(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(_statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40)]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(carModel, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                          child: Text(plate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionCircle(Icons.message_rounded, 'Chat'),
                        _buildActionCircle(Icons.call_rounded, 'Call'),
                        _buildActionCircle(Icons.shield_rounded, 'Safety'),
                        _buildActionCircle(Icons.cancel_outlined, 'Cancel', color: Colors.red, onTap: () => Navigator.pop(context)),
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

  Widget _pinWidget(Color color, IconData icon) => Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]), child: Icon(icon, color: color, size: 20));

  Widget _buildActionCircle(IconData icon, String label, {Color color = Colors.black87, VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
