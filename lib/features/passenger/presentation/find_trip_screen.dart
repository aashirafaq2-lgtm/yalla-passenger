import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import 'map_selection_screen.dart';
import 'wait_screen.dart';

import '../../../core/providers/locale_provider.dart';

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

  // Fallback: all 18 Iraqi governorates — used when the API call fails
  static const List<Map<String, String>> _fallbackGovernorates = [
    {'id': 'gov_baghdad',       'name': 'Baghdad',       'nameAr': 'بغداد'},
    {'id': 'gov_basra',         'name': 'Basra',         'nameAr': 'البصرة'},
    {'id': 'gov_mosul',         'name': 'Mosul',         'nameAr': 'الموصل'},
    {'id': 'gov_erbil',         'name': 'Erbil',         'nameAr': 'أربيل'},
    {'id': 'gov_kirkuk',        'name': 'Kirkuk',        'nameAr': 'كركوك'},
    {'id': 'gov_sulaymaniyah',  'name': 'Sulaymaniyah',  'nameAr': 'السليمانية'},
    {'id': 'gov_najaf',         'name': 'Najaf',         'nameAr': 'النجف'},
    {'id': 'gov_karbala',       'name': 'Karbala',       'nameAr': 'كربلاء'},
    {'id': 'gov_anbar',         'name': 'Anbar',         'nameAr': 'الأنبار'},
    {'id': 'gov_diyala',        'name': 'Diyala',        'nameAr': 'ديالى'},
    {'id': 'gov_babylon',       'name': 'Babylon',       'nameAr': 'بابل'},
    {'id': 'gov_wasit',         'name': 'Wasit',         'nameAr': 'واسط'},
    {'id': 'gov_missan',        'name': 'Missan',        'nameAr': 'ميسان'},
    {'id': 'gov_thiqar',        'name': 'Dhi Qar',       'nameAr': 'ذي قار'},
    {'id': 'gov_qadisiyah',     'name': 'Qadisiyah',     'nameAr': 'القادسية'},
    {'id': 'gov_muthanna',      'name': 'Muthanna',      'nameAr': 'المثنى'},
    {'id': 'gov_saladin',       'name': 'Saladin',       'nameAr': 'صلاح الدين'},
    {'id': 'gov_duhok',         'name': 'Duhok',         'nameAr': 'دهوك'},
  ];

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
        final data = response.data['governorates'];
        if (data is List && data.isNotEmpty) {
          setState(() {
            governorates = data;
            selectedOriginId = governorates[0]['id']?.toString();
            selectedDestinationId = governorates.length > 1
                ? governorates[1]['id']?.toString()
                : governorates[0]['id']?.toString();
            isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    // Fallback to hardcoded Iraqi governorates
    setState(() {
      governorates = _fallbackGovernorates;
      selectedOriginId = _fallbackGovernorates[0]['id'];
      selectedDestinationId = _fallbackGovernorates[1]['id'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                        icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          isArabic ? 'ابحث عن رحلة الآن' : 'Find a trip now',
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 30),
                          ),
                          _buildDropdown(selectedDestinationId, (val) => setState(() => selectedDestinationId = val!)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Number of seats
                      _buildFormRow(
                        isArabic ? 'عدد المقاعد' : 'Number of seats',
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
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      // Front seat
                      _buildFormRow(
                        isArabic ? 'المقعد الأمامي' : 'Front seat',
                        Checkbox(
                          value: frontSeat,
                          onChanged: (val) => setState(() => frontSeat = val!),
                          activeColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      // Choose your location
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapSelectionScreen()),
                          );
                          if (result != null && result is Map) {
                            setState(() {
                              _selectedLocationName = result['name'] ?? result['address'] ?? (isArabic ? 'الموقع المحدد' : 'Selected Location');
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
                                  _selectedLat != null ? _selectedLocationName : (isArabic ? 'حدد موقعك على الخريطة' : 'Choose Your location'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: _selectedLat != null ? Colors.black87 : Colors.black54,
                                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
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
                      // Discount code
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
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: isArabic ? 'كود الخصم' : 'Discount code',
                                  border: InputBorder.none,
                                  hintStyle: const TextStyle(fontSize: 16, color: Colors.black26),
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
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                final code = _discountCtrl.text.trim().toUpperCase();
                                if (code.isEmpty) return;

                                try {
                                  final api = Provider.of<ApiService>(context, listen: false);
                                  final storage = Provider.of<StorageService>(context, listen: false);
                                  final token = await storage.getToken();
                                  final res = await api.validatePromo(code, token);

                                  if (res.statusCode == 200 && res.data['valid'] == true) {
                                    final discount = res.data['discountPercent'] ?? 20;
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isArabic
                                                ? 'تم تطبيق الكود! خصم $discount% على الأجرة.'
                                                : 'Promo code applied! $discount% discount on fare.',
                                          ),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isArabic ? 'كود الخصم غير صحيح. جرب: YALLA20' : 'Invalid promo code. Try: YALLA20 or YALLA50'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Fallback client check if offline
                                  if (code == 'YALLA20' || code == 'YALLA50' || code == 'IRAQ2026') {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isArabic ? 'تم تطبيق الخصم بنجاح!' : 'Promo code applied successfully!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isArabic ? 'كود الخصم غير صحيح. جرب: YALLA20' : 'Invalid promo code. Try: YALLA20 or YALLA50'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Text(isArabic ? 'تطبيق' : 'Apply', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Builder(
                    builder: (context) {
                      const int seatPrice = 20000;
                      final int frontSeatPrice = frontSeat ? 5250 : 0;
                      final int totalSeatsPrice = seats * seatPrice;
                      final int grandTotal = totalSeatsPrice + frontSeatPrice;

                      String formatIqd(int amount) {
                        return amount.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        );
                      }

                      return Column(
                        children: [
                          Text(
                            isArabic ? 'تفاصيل السعر' : 'Price details',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPriceRow(
                            isArabic ? '$seats مقاعد' : '${seats}x seat',
                            isArabic ? '${formatIqd(totalSeatsPrice)} د.ع' : '${formatIqd(totalSeatsPrice)} IQD',
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            isArabic ? 'المقعد الأمامي' : 'Front seat',
                            frontSeat 
                                ? (isArabic ? '${formatIqd(frontSeatPrice)} د.ع' : '${formatIqd(frontSeatPrice)} IQD') 
                                : (isArabic ? 'لا' : 'No'),
                          ),
                          const Divider(height: 32),
                          _buildPriceRow(
                            isArabic ? 'الإجمالي' : 'Total',
                            isArabic ? '${formatIqd(grandTotal)} د.ع' : '${formatIqd(grandTotal)} IQD',
                            isTotal: true,
                          ),
                        ],
                      );
                    },
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
                        final storageService = Provider.of<StorageService>(context, listen: false);
                        final token = await storageService.getToken();
                        if (token == null || token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isArabic ? 'يرجى تسجيل الدخول أولاً لحجز رحلة.' : 'Please sign in first to book a trip.')),
                          );
                          return;
                        }

                        final apiService = Provider.of<ApiService>(context, listen: false);
                        final int seatPrice = 20000;
                        final int frontSeatPrice = frontSeat ? 5250 : 0;
                        final int grandTotal = (seats * seatPrice) + frontSeatPrice;

                        dynamic fromGov;
                        dynamic toGov;
                        try {
                          fromGov = governorates.firstWhere((g) => g['id'] == selectedOriginId);
                        } catch (_) {}
                        try {
                          toGov = governorates.firstWhere((g) => g['id'] == selectedDestinationId);
                        } catch (_) {}

                        final response = await apiService.dio.post(
                          '/bookings/create',
                          data: {
                            'type': 'SCHEDULED',
                            'tripId': 'mock_trip_id',
                            'seatsBooked': seats,
                            'frontSeat': frontSeat,
                            'totalPrice': grandTotal,
                            'pickupName': _selectedLocationName,
                            'dropName': toGov != null ? toGov['name'] : 'Destination',
                            'fromGovernorateId': selectedOriginId,
                            'toGovernorateId': selectedDestinationId,
                            if (_selectedLat != null) 'pickupLat': _selectedLat,
                            if (_selectedLng != null) 'pickupLng': _selectedLng,
                          },
                          options: Options(headers: {'Authorization': 'Bearer $token'}),
                        );
                        if (response.statusCode == 200) {
                          if (!context.mounted) return;
                          final ride = response.data['ride'] ?? response.data['booking'];
                          final rideMap = ride is Map ? Map<String, dynamic>.from(ride) : null;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => WaitScreen(rideData: rideMap)));
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'فشل حجز الرحلة. حاول مرة أخرى.' : 'Booking failed. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      isArabic ? 'ابحث الآن!' : 'Search now!',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.w900,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildDropdown(String? value, ValueChanged<String?> onChanged) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;
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
              final id = gov['id']?.toString() ?? '';
              final displayName = isArabic
                  ? (gov['nameAr'] ?? gov['name'] ?? id)
                  : (gov['name'] ?? id);
              return DropdownMenuItem<String>(
                value: id,
                child: Text(
                  displayName,
                  style: TextStyle(fontFamily: isArabic ? 'NotoKufiArabic' : null),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, Widget action, [bool isArabic = false]) {
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
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 16,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
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
