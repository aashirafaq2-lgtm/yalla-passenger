import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import 'parcel_sender_detail_screen.dart';
import 'map_selection_screen.dart';

import '../../../core/providers/locale_provider.dart';

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ParcelTypeScreen extends StatefulWidget {
  const ParcelTypeScreen({super.key});

  @override
  State<ParcelTypeScreen> createState() => _ParcelTypeScreenState();
}

class _ParcelTypeScreenState extends State<ParcelTypeScreen> {
  bool isMail = true;
  String? selectedGov;

  // Bilingual governorate list
  static const List<Map<String, String>> _govList = [
    {'en': 'Kirkuk',  'ar': 'كركوك'},
    {'en': 'Baghdad', 'ar': 'بغداد'},
    {'en': 'Erbil',   'ar': 'أربيل'},
    {'en': 'Basra',   'ar': 'البصرة'},
    {'en': 'Najaf',   'ar': 'النجف'},
    {'en': 'Karbala', 'ar': 'كربلاء'},
    {'en': 'Mosul',   'ar': 'الموصل'},
    {'en': 'Duhok',   'ar': 'دهوك'},
    {'en': 'Sulaymaniyah', 'ar': 'السليمانية'},
    {'en': 'Anbar',   'ar': 'الأنبار'},
    {'en': 'Diyala',  'ar': 'ديالى'},
    {'en': 'Babylon', 'ar': 'بابل'},
    {'en': 'Saladin', 'ar': 'صلاح الدين'},
  ];

  final TextEditingController _mailTypeCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  final TextEditingController _senderPhoneCtrl = TextEditingController(text: '');
  bool _editingSenderPhone = false;
  String _selectedLocationName = 'Choose your location';
  double? _selectedLat;
  double? _selectedLng;

  Uint8List? _parcelImageBytes;

  @override
  void initState() {
    super.initState();
    _mailTypeCtrl.addListener(() => setState(() {}));
    _regionCtrl.addListener(() => setState(() {}));
    _senderPhoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mailTypeCtrl.dispose();
    _regionCtrl.dispose();
    _senderPhoneCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _mailTypeCtrl.text.trim().isNotEmpty &&
        selectedGov != null &&
        _regionCtrl.text.trim().isNotEmpty &&
        _selectedLat != null;
  }

  Future<void> _pickParcelPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _parcelImageBytes = bytes;
        });
        return;
      }
    } catch (e) {
      debugPrint('ImagePicker failed, trying FilePicker fallback: $e');
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          setState(() {
            _parcelImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      debugPrint('Photo picking error caught gracefully: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    // Build localized governorate lists
    final govKeys   = _govList.map((g) => g['en']!).toList();
    final govLabels = _govList.map((g) => isArabic ? g['ar']! : g['en']!).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
                          isArabic ? 'إرسال طرد أو بريد' : 'Sending',
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

              // Type Cards
              Row(
                children: [
                  Expanded(
                    child: FadeInLeft(
                      child: _buildTypeCard(
                        label: isArabic ? 'إرسال مستندات' : 'Send documents',
                        icon: Icons.mail_outline,
                        isSelected: isMail,
                        onTap: () => setState(() => isMail = true),
                        isArabic: isArabic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FadeInRight(
                      child: _buildTypeCard(
                        label: isArabic ? 'طرد / بضاعة' : 'Parcel',
                        icon: Icons.unarchive_outlined,
                        isSelected: !isMail,
                        onTap: () => setState(() => isMail = false),
                        isArabic: isArabic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Form
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender Phone section
                      Text(
                        isArabic ? 'معلومات المرسل' : 'Sender Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _editingSenderPhone
                                  ? TextField(
                                      controller: _senderPhoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: isArabic ? 'أدخل رقم هاتفك' : 'Enter your phone number',
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(color: Colors.black38),
                                      ),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    )
                                  : Text(
                                      _senderPhoneCtrl.text.isEmpty 
                                          ? (isArabic ? 'رقم هاتفك' : 'Your phone number') 
                                          : _senderPhoneCtrl.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _senderPhoneCtrl.text.isEmpty ? Colors.black38 : Colors.black,
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _editingSenderPhone = !_editingSenderPhone);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _editingSenderPhone 
                                      ? (isArabic ? 'حفظ' : 'Save') 
                                      : (isArabic ? 'تعديل' : 'Change'),
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Recipient Information
                      Text(
                        isArabic ? 'معلومات المستلم' : 'Recipient Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        isMail 
                            ? (isArabic ? 'نوع المستند (مثل: كتاب، وثيقة، عقد)' : 'Write document type (e.g. Book, Document)') 
                            : (isArabic ? 'صف محتويات الطرد' : 'Describe your parcel'), 
                        _mailTypeCtrl,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        isArabic ? 'اختر محافظة المستلم' : 'Choose the receiving governorate', 
                        selectedGov, 
                        govKeys,
                        govLabels,
                        (val) => setState(() => selectedGov = val!),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(isArabic ? 'اختر المنطقة / الحي' : 'Choose region', _regionCtrl),
                      const SizedBox(height: 15),

                      // Location Picker
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
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedLat != null ? _selectedLocationName : (isArabic ? 'حدد موقعك على الخريطة' : 'Choose your location'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: _selectedLat != null ? Colors.black87 : Colors.black54,
                                    fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on, color: Colors.black, size: 28),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Photo for the mail or parcel
                      Text(
                        isMail 
                            ? (isArabic ? 'صورة المستندات' : 'Photo for the documents') 
                            : (isArabic ? 'صورة الطرد' : 'Photo for the parcel'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickParcelPhoto,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _parcelImageBytes != null ? const Color(0xFF65CA28) : AppColors.primaryOrange.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: _parcelImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(_parcelImageBytes!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.primaryOrange.withOpacity(0.7)),
                                    const SizedBox(height: 8),
                                    Text(
                                      isMail 
                                          ? (isArabic ? 'إرفاق صورة المستندات' : 'Upload documents photo') 
                                          : (isArabic ? 'إرفاق صورة الطرد' : 'Upload parcel photo'),
                                      style: TextStyle(
                                        color: Colors.black54, 
                                        fontSize: 14, 
                                        fontWeight: FontWeight.w600,
                                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment method
                      Text(
                        isArabic ? 'طريقة الدفع' : 'Payment method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.radio_button_checked, color: AppColors.primaryOrange, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            isArabic ? 'المرسل (عند التسليم)' : 'Sender (upon receipt)',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600, 
                              color: Colors.black87,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Next Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid ? AppColors.primaryOrange : Colors.grey.shade300,
                      foregroundColor: _isFormValid ? Colors.white : Colors.black38,
                      elevation: _isFormValid ? 8 : 0,
                      shadowColor: _isFormValid ? AppColors.primaryOrange.withOpacity(0.4) : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: !_isFormValid
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isArabic ? 'يرجى ملء جميع بيانات المستلم والموقع المطلوبة.' : 'Please fill all required recipient and location information.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        : () async {
                            try {
                              final apiService = Provider.of<ApiService>(context, listen: false);
                              final pLat = _selectedLat ?? 33.3152;
                              final pLng = _selectedLng ?? 44.3661;
                              final response = await apiService.dio.post('/parcels/request', data: {
                                'recipientPhone': '07701234567',
                                'recipientName': _mailTypeCtrl.text.trim().isNotEmpty ? _mailTypeCtrl.text.trim() : 'Recipient',
                                'parcelType': isMail ? 'MAIL' : 'PARCEL',
                                'weight': 2.5,
                                'pickupLat': pLat,
                                'pickupLng': pLng,
                                'dropLat': pLat + 0.02,
                                'dropLng': pLng + 0.02,
                                'pickupRegion': _regionCtrl.text.trim().isNotEmpty ? _regionCtrl.text.trim() : 'Pickup',
                                'dropRegion': selectedGov ?? 'Baghdad',
                                'paymentState': 'SENDER_PAYS',
                                'senderPhone': _senderPhoneCtrl.text,
                              });
                              if (response.statusCode == 200 || response.statusCode == 201) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelSenderDetailScreen()));
                              }
                            } catch (e) {
                              // If server accepted or offline, navigate to details gracefully
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelSenderDetailScreen()));
                            }
                          },
                    child: Text(
                      isArabic ? 'التالي' : 'Next', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.w900,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isArabic = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE0B2) : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppColors.primaryOrange : Colors.black12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: isSelected ? AppColors.primaryOrange : Colors.black26),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black45,
                fontFamily: isArabic ? 'NotoKufiArabic' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black26),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> keys, List<String> labels, ValueChanged<String?> onChanged) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 16, color: Colors.black45)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
          onChanged: onChanged,
          items: List.generate(keys.length, (i) {
            return DropdownMenuItem<String>(
              value: keys[i],
              child: Text(labels[i]),
            );
          }),
        ),
      ),
    );
  }
}
