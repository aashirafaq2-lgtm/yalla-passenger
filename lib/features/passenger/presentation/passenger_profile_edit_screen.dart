import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';

class PassengerProfileEditScreen extends StatefulWidget {
  final dynamic currentUser;
  const PassengerProfileEditScreen({super.key, this.currentUser});

  @override
  State<PassengerProfileEditScreen> createState() => _PassengerProfileEditScreenState();
}

class _PassengerProfileEditScreenState extends State<PassengerProfileEditScreen> {
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _firstNameCtrl.text = (widget.currentUser['firstName'] ?? '').toString();
      _lastNameCtrl.text = (widget.currentUser['lastName'] ?? '').toString();
      _emailCtrl.text = (widget.currentUser['email'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.isArabic;

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token = await storage.getToken();

      if (token != null) {
        await api.updateProfile({
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        }, token);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم حفظ البيانات بنجاح' : 'Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            FadeInDown(
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8F8F8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 50, color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildField(
              controller: _firstNameCtrl,
              label: isArabic ? 'الاسم الأول' : 'First Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 18),

            _buildField(
              controller: _lastNameCtrl,
              label: isArabic ? 'اسم العائلة' : 'Last Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 18),

            _buildField(
              controller: _emailCtrl,
              label: isArabic ? 'البريد الإلكتروني' : 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),

            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(
                          isArabic ? 'حفظ التغييرات' : 'Save Changes',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
