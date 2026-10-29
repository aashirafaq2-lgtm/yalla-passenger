import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import 'parcel_booking_model.dart';
import 'parcel_summary_screen.dart';

class ParcelReceiverDetailScreen extends StatefulWidget {
  final ParcelBookingData bookingData;

  const ParcelReceiverDetailScreen({super.key, required this.bookingData});

  @override
  State<ParcelReceiverDetailScreen> createState() => _ParcelReceiverDetailScreenState();
}

class _ParcelReceiverDetailScreenState extends State<ParcelReceiverDetailScreen> {
  final TextEditingController _receiverNameCtrl = TextEditingController();
  final TextEditingController _receiverPhoneCtrl = TextEditingController();
  final TextEditingController _receiverAreaCtrl = TextEditingController();
  final TextEditingController _receiverAddressCtrl = TextEditingController();
  String? _selectedReceiverGov;

  static const List<Map<String, String>> _govList = [
    {'en': 'Kirkuk',        'ar': 'كركوك'},
    {'en': 'Baghdad',       'ar': 'بغداد'},
    {'en': 'Erbil',         'ar': 'أربيل'},
    {'en': 'Basra',         'ar': 'البصرة'},
    {'en': 'Najaf',         'ar': 'النجف'},
    {'en': 'Karbala',       'ar': 'كربلاء'},
    {'en': 'Mosul',         'ar': 'الموصل'},
    {'en': 'Duhok',         'ar': 'دهوك'},
    {'en': 'Sulaymaniyah',  'ar': 'السليمانية'},
    {'en': 'Anbar',         'ar': 'الأنبار'},
    {'en': 'Diyala',        'ar': 'ديالى'},
    {'en': 'Babylon',       'ar': 'بابل'},
    {'en': 'Saladin',       'ar': 'صلاح الدين'},
    {'en': 'Wasit',         'ar': 'واسط'},
    {'en': 'Maysan',        'ar': 'ميسان'},
    {'en': 'Muthanna',      'ar': 'المثنى'},
    {'en': 'Qadisiyyah',    'ar': 'القادسية'},
    {'en': 'Dhi Qar',       'ar': 'ذي قار'},
  ];

  @override
  void initState() {
    super.initState();
    _receiverNameCtrl.text = widget.bookingData.receiverName;
    _receiverPhoneCtrl.text = widget.bookingData.receiverPhone;
    _receiverAreaCtrl.text = widget.bookingData.receiverArea;
    _receiverAddressCtrl.text = widget.bookingData.receiverAddress;
    _selectedReceiverGov = widget.bookingData.receiverGovernorate;
  }

  @override
  void dispose() {
    _receiverNameCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _receiverAreaCtrl.dispose();
    _receiverAddressCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    final name = _receiverNameCtrl.text.trim();
    final phone = _receiverPhoneCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى إدخال اسم المستلم' : 'Please enter receiver name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى إدخال رقم هاتف المستلم' : 'Please enter receiver phone number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedReceiverGov == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى اختيار محافظة المستلم' : 'Please choose receiver governorate'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Save into booking data
    widget.bookingData.receiverName = name;
    widget.bookingData.receiverPhone = phone;
    widget.bookingData.receiverGovernorate = _selectedReceiverGov;
    widget.bookingData.receiverArea = _receiverAreaCtrl.text.trim().isNotEmpty
        ? _receiverAreaCtrl.text.trim()
        : (isArabic ? 'المركز' : 'Center');
    widget.bookingData.receiverAddress = _receiverAddressCtrl.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParcelSummaryScreen(bookingData: widget.bookingData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final govKeys = _govList.map((g) => g['en']!).toList();
    final govLabels = _govList.map((g) => isArabic ? g['ar']! : g['en']!).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header matching screenshot 2
            Padding(
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
                      child: Text(
                        isArabic ? 'المستلم' : 'Receiver',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for circular back button
                ],
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Receiver Card
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'معلومات المستلم' : 'Receiver Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: isArabic ? 'NotoKufiArabic' : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Field 1: Receiver Name
                            _buildInputField(
                              icon: Icons.person_outline,
                              hint: isArabic ? 'اسم المستلم' : 'Receiver name',
                              controller: _receiverNameCtrl,
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 14),

                            // Field 2: Receiver Phone
                            _buildInputField(
                              icon: Icons.phone_outlined,
                              hint: isArabic ? 'رقم هاتف المستلم' : 'Receiver phone number',
                              controller: _receiverPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 14),

                            // Field 3: Receiver Governorate Dropdown
                            _buildGovDropdown(
                              icon: Icons.account_balance_outlined,
                              hint: isArabic ? 'اختر محافظة المستلم' : 'Choose the receiver governorate',
                              value: _selectedReceiverGov,
                              keys: govKeys,
                              labels: govLabels,
                              onChanged: (val) => setState(() => _selectedReceiverGov = val),
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 14),

                            // Field 4: Enter Area
                            _buildInputField(
                              icon: Icons.map_outlined,
                              hint: isArabic ? 'أدخل المنطقة' : 'Enter area',
                              controller: _receiverAreaCtrl,
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 14),

                            // Field 5: Receiver Address (optional)
                            _buildAddressField(
                              icon: Icons.location_on_outlined,
                              titleHint: isArabic ? 'عنوان المستلم' : 'Receiver address',
                              subtitleHint: isArabic
                                  ? 'الشارع، المنطقة، أو نقطة دالة (اختياري)'
                                  : 'Street, area, or landmark (optional)',
                              controller: _receiverAddressCtrl,
                              isArabic: isArabic,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: AppColors.primaryOrange.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _onNext,
                          child: Text(
                            isArabic ? 'التالي' : 'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required bool isArabic,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: isArabic ? 'NotoKufiArabic' : null,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black38,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovDropdown({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> keys,
    required List<String> labels,
    required ValueChanged<String?> onChanged,
    required bool isArabic,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black38,
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 24),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
                onChanged: onChanged,
                items: List.generate(keys.length, (i) {
                  return DropdownMenuItem<String>(
                    value: keys[i],
                    child: Text(labels[i]),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField({
    required IconData icon,
    required String titleHint,
    required String subtitleHint,
    required TextEditingController controller,
    required bool isArabic,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(icon, color: Colors.black45, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 2,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                  ),
                  decoration: InputDecoration(
                    hintText: titleHint,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                    helperText: subtitleHint,
                    helperStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

