import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/storage_service.dart';
import 'map_selection_screen.dart';
import 'parcel_booking_model.dart';
import 'parcel_receiver_detail_screen.dart';

class ParcelTypeScreen extends StatefulWidget {
  const ParcelTypeScreen({super.key});

  @override
  State<ParcelTypeScreen> createState() => _ParcelTypeScreenState();
}

class _ParcelTypeScreenState extends State<ParcelTypeScreen> {
  // Sender phone & editing
  final TextEditingController _senderPhoneCtrl = TextEditingController(text: '');
  bool _editingSenderPhone = false;

  // Document & Location
  final TextEditingController _documentTypeCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  String? _selectedSenderGov;

  String _selectedLocationName = 'Choose your location';
  double? _selectedLat;
  double? _selectedLng;

  Uint8List? _documentImageBytes;

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
    _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final phone = await storage.getUserPhone();
      if (phone != null && phone.isNotEmpty && _senderPhoneCtrl.text.isEmpty) {
        setState(() {
          _senderPhoneCtrl.text = phone;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _senderPhoneCtrl.dispose();
    _documentTypeCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocumentPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _documentImageBytes = bytes;
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
            _documentImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      debugPrint('Photo picking error caught: $e');
    }
  }

  void _onNext() {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    if (_documentTypeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى كتابة نوع المستند' : 'Please enter document type'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedSenderGov == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى اختيار محافظة الإرسال' : 'Please choose the sender governorate'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_regionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى إدخال منطقة الإرسال' : 'Please enter sender region'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final bookingData = ParcelBookingData(
      senderName: isArabic ? 'المرسل' : 'Sender',
      senderPhone: _senderPhoneCtrl.text.trim().isNotEmpty ? _senderPhoneCtrl.text.trim() : '07701234567',
      documentType: _documentTypeCtrl.text.trim(),
      senderGovernorate: _selectedSenderGov,
      senderRegion: _regionCtrl.text.trim(),
      senderLocationName: _selectedLocationName,
      senderLat: _selectedLat ?? 33.3152,
      senderLng: _selectedLng ?? 44.3661,
      documentImageBytes: _documentImageBytes,
      paymentMethod: 'Sender (Pay in advance)',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParcelReceiverDetailScreen(bookingData: bookingData),
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
            // Header
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
                        isArabic ? 'معلومات المرسل' : 'Sender Information',
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
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender Information Section
                    Text(
                      isArabic ? 'معلومات المرسل' : 'Sender Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone Number with Change Button (Matching Screenshot 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                                      hintText: isArabic ? 'أدخل رقم هاتفك' : 'Your phone number',
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
                                      color: _senderPhoneCtrl.text.isEmpty ? Colors.black38 : Colors.black87,
                                    ),
                                  ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _editingSenderPhone = !_editingSenderPhone);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8D6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _editingSenderPhone
                                    ? (isArabic ? 'حفظ' : 'Save')
                                    : (isArabic ? 'تعديل' : 'Change'),
                                style: const TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Document Details Form Fields
                    _buildTextField(
                      hint: isArabic
                          ? 'اكتب نوع المستند (مثل: كتاب، وثيقة...)'
                          : 'Write document type (e.g. Book, D...)',
                      controller: _documentTypeCtrl,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 14),

                    _buildDropdown(
                      hint: isArabic ? 'اختر محافظة الإرسال' : 'Choose the sender governorate',
                      value: _selectedSenderGov,
                      keys: govKeys,
                      labels: govLabels,
                      onChanged: (val) => setState(() => _selectedSenderGov = val),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 14),

                    _buildTextField(
                      hint: isArabic ? 'اختر المنطقة' : 'Choose region',
                      controller: _regionCtrl,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 14),

                    // Location Picker
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MapSelectionScreen()),
                        );
                        if (result != null && result is Map) {
                          setState(() {
                            _selectedLocationName = result['name'] ??
                                result['address'] ??
                                (isArabic ? 'الموقع المحدد' : 'Selected Location');
                            _selectedLat = result['lat'] as double?;
                            _selectedLng = result['lng'] as double?;
                          });
                        }
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedLat != null
                                    ? _selectedLocationName
                                    : (isArabic ? 'اختر موقعك على الخريطة' : 'Choose your location'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: _selectedLat != null ? Colors.black87 : Colors.black38,
                                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on, color: Colors.black, size: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Photo for the documents
                    Text(
                      isArabic ? 'صورة المستندات' : 'Photo for the documents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDocumentPhoto,
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _documentImageBytes != null
                                ? const Color(0xFF65CA28)
                                : AppColors.primaryOrange.withOpacity(0.35),
                            width: 1.5,
                          ),
                        ),
                        child: _documentImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(_documentImageBytes!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.primaryOrange),
                                  const SizedBox(height: 8),
                                  Text(
                                    isArabic ? 'إرفاق صورة المستندات' : 'Upload documents photo',
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
                    const SizedBox(height: 24),

                    // Payment method
                    Text(
                      isArabic ? 'طريقة الدفع' : 'Payment method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked, color: AppColors.primaryOrange, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          isArabic ? 'المرسل (دفع مسبق)' : 'Sender (Pay in advance)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // Next Button
                    SizedBox(
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required bool isArabic,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: TextField(
          controller: controller,
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
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> keys,
    required List<String> labels,
    required ValueChanged<String?> onChanged,
    required bool isArabic,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black38,
              fontFamily: isArabic ? 'NotoKufiArabic' : null,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 26),
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
    );
  }
}
