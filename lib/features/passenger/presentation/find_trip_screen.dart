import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import 'map_selection_screen.dart';
import 'wait_screen.dart';

class FindTripScreen extends StatefulWidget {
  const FindTripScreen({super.key});

  @override
  State<FindTripScreen> createState() => _FindTripScreenState();
}

class _FindTripScreenState extends State<FindTripScreen> {
  int seats = 1;
  bool frontSeat = false;
  String? selectedOriginId;
  String? selectedDestinationId;
  List<dynamic> governorates = [];
  bool isLoading = true;
  final TextEditingController _discountCtrl = TextEditingController();
  bool _hasDiscountCode = false;
  String _selectedLocationName = 'Choose Your location';
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
    _discountCtrl.addListener(() {
      setState(() => _hasDiscountCode = _discountCtrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGovernorates() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getGovernorates();
      if (response.statusCode == 200) {
        setState(() {
          governorates = response.data['governorates'];
          if (governorates.isNotEmpty) {
            selectedOriginId = governorates[0]['id'];
            selectedDestinationId = governorates.length > 1 ? governorates[1]['id'] : governorates[0]['id'];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              FadeInDown(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Find a trip now',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Selection Form Card
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Source to Destination
                      Row(
                        children: [
                          _buildDropdown(selectedOriginId, (val) => setState(() => selectedOriginId = val!)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.arrow_right_alt, size: 30),
                          ),
                          _buildDropdown(selectedDestinationId, (val) => setState(() => selectedDestinationId = val!)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Number of seats
                      _buildFormRow(
                        'Number of seats',
                        Row(
                          children: [
                            _buildCounterButton(Icons.remove, () {
                              if (seats > 1) setState(() => seats--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$seats', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            _buildCounterButton(Icons.add, () {
                              setState(() => seats++);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Front seat
                      _buildFormRow(
                        'Front seat',
                        Checkbox(
                          value: frontSeat,
                          onChanged: (val) => setState(() => frontSeat = val!),
                          activeColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Choose your location (per Figure 1)
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapSelectionScreen()),
                          );
                          if (result != null && result is Map) {
                            setState(() {
                              _selectedLocationName = result['name'] ?? result['address'] ?? 'Selected Location';
                              _selectedLat = result['lat'] as double?;
                              _selectedLng = result['lng'] as double?;
                            });
                          }
                        },
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedLocationName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: _selectedLat != null ? Colors.black87 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Discount code — Apply turns dark orange when code entered
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                controller: _discountCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Discount code',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasDiscountCode
                                    ? AppColors.primaryDark
                                    : AppColors.primaryOrange.withOpacity(0.7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid discount code')),
                                );
                              },
                              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Price Details
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Price details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow('1x seat', '75,000 IQD'),
                      const SizedBox(height: 12),
                      _buildPriceRow('Front seat', frontSeat ? '5,000 IQD' : 'No'),
                      const Divider(height: 32),
                      _buildPriceRow('Total', '25,250 IQD', isTotal: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Search Button — no Pulse animation per design notes
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shadowColor: Colors.black26,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      try {
                        final apiService = Provider.of<ApiService>(context, listen: false);
                        final response = await apiService.dio.post('/bookings/create', data: {
                          'type': 'SCHEDULED_SEAT',
                          'tripId': 'mock_trip_id',
                          'seatsBooked': seats,
                        });
                        if (response.statusCode == 200) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WaitScreen()));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Booking failed: $e')),
                        );
                      }
                    },
                    child: const Text(
                      'Search now!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            onChanged: onChanged,
            items: governorates.map<DropdownMenuItem<String>>((dynamic gov) {
              return DropdownMenuItem<String>(
                value: gov['id'],
                child: Text(gov['name']),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, Widget action) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          action,
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 20 : 17,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: isTotal ? Colors.black : Colors.black54,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 20 : 17,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          color: Colors.black,
        )),
      ],
    );
  }
}
