import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
  Timer? _debounceTimer;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ?? const LatLng(33.3152, 44.3661); // Baghdad default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(_currentCenter);
    });
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
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
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
        setState(() {
          _selectedAddressName = res.data['name'] ?? 'Selected Pin Location';
          _selectedFullAddress = res.data['formattedAddress'] ?? 'Iraq';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddressName = 'Pinned Location';
          _selectedFullAddress = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
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
        setState(() {
          _searchResults = res.data['results'] ?? [];
          _isSearching = false;
          _showSearchResults = _searchResults.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(dynamic place) {
    final lat = (place['lat'] as num).toDouble();
    final lng = (place['lng'] as num).toDouble();
    final newPos = LatLng(lat, lng);

    _mapController.move(newPos, 15.5);
    setState(() {
      _currentCenter = newPos;
      _selectedAddressName = place['name'] ?? 'Selected Place';
      _selectedFullAddress = place['formattedAddress'] ?? '';
      _showSearchResults = false;
      _searchController.text = _selectedAddressName;
    });
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
          // ─── HIGH DEFINITION RETINA MAP ───
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
              // OpenStreetMap HD Clean Tiles (100% Free & No Watermark)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yalla.passenger',
                maxZoom: 19,
              ),
            ],
          ),

          // ─── CENTER TARGET PIN ───
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
                            'Drag map to position',
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

          // ─── TOP SEARCH & BACK BAR ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Back Button
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

                      // Search Input Box
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
                            decoration: InputDecoration(
                              hintText: 'Search place, mall, street in Iraq...',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                              prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: Colors.black45),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _showSearchResults = false);
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

                  // Search Results Dropdown List
                  if (_showSearchResults && _searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      constraints: const BoxConstraints(maxHeight: 240),
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
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final place = _searchResults[idx];
                          return ListTile(
                            leading: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFFFF7ED),
                              child: Icon(Icons.place_outlined, color: AppColors.primaryOrange, size: 18),
                            ),
                            title: Text(
                              place['name'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              place['formattedAddress'] ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(place),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── BOTTOM ADDRESS CONFIRMATION CARD ───
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
                          child: Column(
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

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _confirmSelection,
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
        ],
      ),
    );
  }
}
