import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String title;

  const MapSelectionScreen({
    super.key,
    this.initialPosition,
    this.title = 'Select Location',
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  String _selectedAddressName = 'Locating address...';
  String _selectedFullAddress = 'Iraq';
  bool _isLoadingAddress = false;
  bool _isLoadingPlace = false;
  Timer? _debounceTimer;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchPredictions = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ?? const LatLng(33.3412, 44.4009);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDeviceLocation();
    });
  }

  /// Fetch real GPS location from device, fallback to map center if denied
  Future<void> _fetchDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _reverseGeocode(_currentCenter);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _reverseGeocode(_currentCenter);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
      final gpsPos = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() => _currentCenter = gpsPos);
        try {
          _mapController.move(gpsPos, 15.5);
        } catch (_) {}
        _reverseGeocode(gpsPos);
      }
    } catch (_) {
      _reverseGeocode(_currentCenter);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _currentCenter = camera.center;
      setState(() {
        _selectedAddressName = 'Locating address...';
        _isLoadingAddress = true;
      });
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 700), () {
        _reverseGeocode(_currentCenter);
      });
    }
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.reverseGeocode(pos.latitude, pos.longitude);

      if (mounted && res.data != null) {
        // Backend returns: { address: "formatted_address", results: [...] }
        final address = res.data['address']?.toString() ?? '';
        final results = res.data['results'] as List? ?? [];

        String shortName = address;
        // Try to extract short name from address_components
        if (results.isNotEmpty && results[0]['address_components'] != null) {
          final components = results[0]['address_components'] as List;
          String? extractedName;
          for (final component in components) {
            final types = (component['types'] as List?) ?? [];
            if (types.contains('neighborhood') || types.contains('sublocality_level_1') || types.contains('route')) {
              extractedName = component['long_name']?.toString();
              break;
            }
          }
          if (extractedName != null && extractedName.isNotEmpty) {
            shortName = extractedName;
          }
        }

        setState(() {
          _selectedAddressName = shortName.isNotEmpty ? shortName : 'Selected Location';
          _selectedFullAddress = address.isNotEmpty ? address : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddressName = 'Pinned Location';
          _selectedFullAddress = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchPredictions = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.searchLocation(
        query,
        lat: _currentCenter.latitude,
        lng: _currentCenter.longitude,
      );

      if (mounted && res.data != null) {
        // Backend /api/map/search returns { predictions: [{placeId, description, mainText, secondaryText}] }
        final predictions = res.data['predictions'] as List? ?? [];
        setState(() {
          _searchPredictions = predictions;
          _isSearching = false;
          _showSearchResults = predictions.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  /// Resolve a Google placeId → lat/lng via /api/map/place-details, then move map
  Future<void> _selectPrediction(dynamic prediction) async {
    final placeId = prediction['placeId']?.toString() ?? '';
    final displayName = (prediction['mainText'] ?? prediction['description'] ?? 'Selected Place').toString();
    final fullAddress = (prediction['description'] ?? '').toString();

    setState(() {
      _showSearchResults = false;
      _searchController.text = displayName;
      _isLoadingPlace = true;
      _selectedAddressName = displayName;
      _selectedFullAddress = fullAddress;
    });

    if (placeId.isEmpty) {
      setState(() => _isLoadingPlace = false);
      return;
    }

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.getPlaceDetails(placeId);

      if (mounted && res.data != null) {
        final lat = (res.data['lat'] as num?)?.toDouble();
        final lng = (res.data['lng'] as num?)?.toDouble();
        final address = res.data['address']?.toString() ?? fullAddress;
        final name = res.data['name']?.toString() ?? displayName;

        if (lat != null && lng != null) {
          final newPos = LatLng(lat, lng);
          setState(() {
            _currentCenter = newPos;
            _selectedAddressName = name;
            _selectedFullAddress = address;
            _isLoadingPlace = false;
          });
          try {
            _mapController.move(newPos, 16.0);
          } catch (_) {}
        } else {
          setState(() => _isLoadingPlace = false);
        }
      } else {
        setState(() => _isLoadingPlace = false);
      }
    } catch (e) {
      debugPrint('[MapSearch] Place details error: $e');
      if (mounted) setState(() => _isLoadingPlace = false);
    }
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'name': _selectedAddressName,
      'address': _selectedFullAddress,
      'lat': _currentCenter.latitude,
      'lng': _currentCenter.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── MAP ───
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14.5,
              onPositionChanged: _onPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yalla.passenger',
                maxZoom: 19,
              ),
            ],
          ),

          // ─── CENTER PIN ───
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 42),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: _isLoadingAddress
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Drag to position',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.primaryOrange,
                  ),
                ],
              ),
            ),
          ),

          // ─── TOP SEARCH BAR ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchPlaces,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مكان... / Search a place...',
                              hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black45),
                              prefixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                                      ),
                                    )
                                  : const Icon(Icons.search, color: AppColors.primaryOrange),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: Colors.black45),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _showSearchResults = false;
                                          _searchPredictions = [];
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Predictions Dropdown
                  if (_showSearchResults && _searchPredictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      constraints: const BoxConstraints(maxHeight: 280),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: _searchPredictions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                        itemBuilder: (ctx, idx) {
                          final place = _searchPredictions[idx];
                          final secondary = (place['secondaryText'] ?? '').toString();
                          return ListTile(
                            dense: true,
                            leading: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFFFF7ED),
                              child: Icon(Icons.place_outlined, color: AppColors.primaryOrange, size: 18),
                            ),
                            title: Text(
                              (place['mainText'] ?? place['description'] ?? '').toString(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: secondary.isNotEmpty
                                ? Text(
                                    secondary,
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () => _selectPrediction(place),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── BOTTOM CONFIRM CARD ───
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFFF7ED),
                          child: Icon(Icons.location_on, color: AppColors.primaryOrange, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _isLoadingPlace
                              ? const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Resolving location...', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                    SizedBox(height: 6),
                                    LinearProgressIndicator(color: AppColors.primaryOrange),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedAddressName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _selectedFullAddress,
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _isLoadingPlace ? null : _confirmSelection,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm This Location',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── My Location FAB ──
          Positioned(
            bottom: 215,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              elevation: 6,
              heroTag: 'myLocationBtnMapSelect',
              onPressed: _fetchDeviceLocation,
              child: const Icon(Icons.my_location, color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
