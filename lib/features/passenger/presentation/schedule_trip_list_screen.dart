import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'schedule_trip_config_screen.dart';

class ScheduleTripListScreen extends StatefulWidget {
  const ScheduleTripListScreen({super.key});

  @override
  State<ScheduleTripListScreen> createState() => _ScheduleTripListScreenState();
}

class _ScheduleTripListScreenState extends State<ScheduleTripListScreen> {
  String filterOrigin = 'Kirkuk';
  String filterDest = 'Baghdad';
  final List<String> cities = ['Kirkuk', 'Baghdad', 'Erbil', 'Basra', 'Sulaymaniyah', 'Najaf', 'Karbala', 'Mosul', 'Dohuk', 'Anbar', 'Babel', 'Wasit'];
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.dio.get('/trips/available');
      if (res.statusCode == 200 && res.data['trips'] != null) {
        final allTrips = List<dynamic>.from(res.data['trips']);
        setState(() {
          _trips = allTrips;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Load available trips error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = _trips.where((t) {
      if (query.isEmpty) return true;
      final from = (t['fromGovernorate']?['name'] ?? '').toString().toLowerCase();
      final to = (t['toGovernorate']?['name'] ?? '').toString().toLowerCase();
      return from.contains(query) || to.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        child: _isSearching
                            ? TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: isArabic ? 'ابحث عن الرحلات...' : 'Search trips...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                onChanged: (val) => setState(() {}),
                              )
                            : Text(
                                isArabic ? 'رحلة مجدولة' : 'Schedule a trip',
                                style: TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                ),
                              ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) _searchCtrl.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Prominent Search & Quick Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primaryOrange, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'ابحث باسم المحافظة (مثل: كركوك، بغداد)...' : 'Search by governorate (e.g. Kirkuk, Baghdad)...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.black45, fontFamily: isArabic ? 'NotoKufiArabic' : null),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.black45),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isArabic ? 'بحث' : 'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Trip List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : RefreshIndicator(
                      color: AppColors.primaryOrange,
                      onRefresh: _loadTrips,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        children: [
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text(
                                      isArabic ? 'لا توجد رحلات مجدولة متاحة حالياً' : 'No scheduled trips available right now',
                                      style: TextStyle(
                                        color: Colors.grey.shade600, 
                                        fontSize: 15, 
                                        fontWeight: FontWeight.bold,
                                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ...List.generate(filtered.length, (index) {
                            final t = filtered[index];
                            final from = t['fromGovernorate']?['name'] ?? (isArabic ? 'كركوك' : 'Kirkuk');
                            final to = t['toGovernorate']?['name'] ?? (isArabic ? 'بغداد' : 'Baghdad');
                            final seats = (t['availableSeats'] ?? 4).toString();
                            final price = '${t['pricePerSeat'] ?? 15000} ${isArabic ? "د.ع" : "IQD"}';
                            final car = t['carType']?['name'] ?? t['driver']?['vehicle']?['model'] ?? 'Dodge Charger';
                            final dateRaw = t['departureTime'];
                            String date = isArabic ? 'اليوم' : 'Today';
                            String time = '2:00 PM';
                            if (dateRaw != null) {
                              try {
                                final dt = DateTime.parse(dateRaw.toString()).toLocal();
                                date = '${dt.day}/${dt.month}/${dt.year}';
                                final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                                final amPm = dt.hour >= 12 ? (isArabic ? 'م' : 'PM') : (isArabic ? 'ص' : 'AM');
                                time = '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
                              } catch (_) {}
                            }

                            final driverName = [t['driver']?['firstName'], t['driver']?['lastName']]
                                .where((v) => v != null && v.toString().isNotEmpty).join(' ');

                            return _buildTripCard(
                              context,
                              tripId: t['id']?.toString(),
                              from: from,
                              to: to,
                              time: time,
                              date: date,
                              seats: seats,
                              price: price,
                              car: car,
                              index: index,
                              isArabic: isArabic,
                              pricePerSeat: t['pricePerSeat'] ?? 15000,
                              driverName: driverName.isEmpty ? 'Driver' : driverName,
                            );
                          }),
                          _buildInteractiveFilterCard(isArabic),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    String? tripId,
    required String from,
    required String to,
    required String time,
    required String date,
    required String seats,
    required String price,
    required String car,
    required int index,
    bool isArabic = false,
    dynamic pricePerSeat,
    String driverName = 'Driver',
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Route
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCityBadge(from),
                Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 30),
                _buildCityBadge(to),
              ],
            ),
            const SizedBox(height: 20),
            // Info Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.accessible_forward, seats, isArabic ? 'المقاعد' : 'Seats'),
                _buildInfoItem(Icons.access_time_filled, time, isArabic ? 'الوقت' : 'Time'),
                _buildInfoItem(Icons.calendar_month, date, isArabic ? 'التاريخ' : 'Date'),
              ],
            ),
            const SizedBox(height: 20),
            // Sub Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(isArabic ? 'السعر' : 'Price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.directions_car, size: 24),
                    Text(car, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Driver info row
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(Icons.person, color: AppColors.primaryOrange, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driverName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Book Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleTripConfigScreen(
                        tripId: tripId,
                        initialOrigin: from,
                        initialDestination: to,
                        isStaticCity: true,
                        pricePerSeat: pricePerSeat ?? 15000,
                        driverName: driverName,
                      ),
                    ),
                  );
                },
                child: Text(
                  isArabic ? 'احجز الآن' : 'Book now', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCityBadge(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: AppColors.primaryOrange.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: Text(
        city,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildInteractiveFilterCard([bool isArabic = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(
            isArabic ? 'بحث عن رحلة' : 'Search for a Trip',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterBadge(filterOrigin, (val) => setState(() => filterOrigin = val!)),
              const Icon(Icons.arrow_forward, size: 28, color: Colors.black54),
              _buildFilterBadge(filterDest, (val) => setState(() => filterDest = val!)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                _searchCtrl.text = filterOrigin;
                setState(() {});
                _loadTrips();
              },
              icon: const Icon(Icons.search, size: 20),
              label: Text(
                isArabic ? 'بحث عن رحلات' : 'Search Trips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String value, ValueChanged<String?> onChanged) {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: cities.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
