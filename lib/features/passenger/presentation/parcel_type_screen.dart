import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import 'parcel_sender_detail_screen.dart';
import 'map_selection_screen.dart';

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ParcelTypeScreen extends StatefulWidget {
  const ParcelTypeScreen({super.key});

  @override
  State<ParcelTypeScreen> createState() => _ParcelTypeScreenState();
}

class _ParcelTypeScreenState extends State<ParcelTypeScreen> {
  bool isMail = true;
  String? selectedGov;
  final List<String> governorates = ['Kirkuk', 'Bagdad', 'Erbil', 'Basra', 'Najaf', 'Karbala', 'Mosul'];
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _parcelImageBytes = result.files.single.bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Sending',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                        label: 'Send documents',
                        icon: Icons.mail_outline,
                        isSelected: isMail,
                        onTap: () => setState(() => isMail = true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FadeInRight(
                      child: _buildTypeCard(
                        label: 'Parcel',
                        icon: Icons.unarchive_outlined,
                        isSelected: !isMail,
                        onTap: () => setState(() => isMail = false),
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
                      const Text(
                        'Sender Information',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your phone number',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.black38),
                                      ),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    )
                                  : Text(
                                      _senderPhoneCtrl.text.isEmpty ? 'Your phone number' : _senderPhoneCtrl.text,
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
                                  _editingSenderPhone ? 'Save' : 'Change',
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

                      // Recipient Information
                      const Text(
                        'Recipient Information',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(isMail ? 'Write document type (e.g. Book, Document)' : 'Describe your parcel', _mailTypeCtrl),
                      const SizedBox(height: 15),
                      _buildDropdown('Choose the receiving governorate', selectedGov, governorates, (val) => setState(() => selectedGov = val!)),
                      const SizedBox(height: 15),
                      _buildTextField('Choose region', _regionCtrl),
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
                              _selectedLocationName = result['name'] ?? result['address'] ?? 'Selected Location';
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
                                  _selectedLocationName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: _selectedLat != null ? Colors.black87 : Colors.black54,
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
                        isMail ? 'Photo for the documents' : 'Photo for the parcel',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                                      isMail ? 'Upload documents photo' : 'Upload parcel photo',
                                      style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment method (Only sender pay - fixed)
                      const Text(
                        'Payment method',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.radio_button_checked, color: AppColors.primaryOrange, size: 22),
                          const SizedBox(width: 10),
                          const Text(
                            'Sender (upon receipt)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Next Button — Active only when form is valid
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
                              const SnackBar(
                                content: Text('Please fill all required recipient and location information.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        : () async {
                            try {
                              final apiService = Provider.of<ApiService>(context, listen: false);
                              final response = await apiService.dio.post('/parcels/request', data: {
                                'recipientPhone': '07701234567',
                                'recipientName': 'Hassan',
                                'parcelType': isMail ? 'MAIL' : 'PARCEL',
                                'weight': 2.5,
                                'pickupLat': _selectedLat ?? 33.3,
                                'pickupLng': _selectedLng ?? 44.4,
                                'pickupRegion': _regionCtrl.text,
                                'dropRegion': selectedGov ?? 'Bagdad',
                                'paymentState': 'SENDER_PAYS',
                                'senderPhone': _senderPhoneCtrl.text,
                              });
                              if (response.statusCode == 200) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelSenderDetailScreen()));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                    child: const Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
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

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
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
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
