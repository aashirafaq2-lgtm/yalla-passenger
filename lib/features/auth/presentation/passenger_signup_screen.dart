import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/deferred_link_service.dart';
import 'passenger_otp_screen.dart';

class PassengerSignUpScreen extends StatefulWidget {
  const PassengerSignUpScreen({super.key});

  @override
  State<PassengerSignUpScreen> createState() => _PassengerSignUpScreenState();
}

class _PassengerSignUpScreenState extends State<PassengerSignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String? _detectedReferralCode;

  @override
  void initState() {
    super.initState();
    _checkPendingReferral();
  }

  Future<void> _checkPendingReferral() async {
    final code = await DeferredLinkService.getPendingReferralCode();
    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        _detectedReferralCode = code;
        _referralController.text = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Invited! Referral code "$code" applied automatically.'),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.primaryOrange,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── White Card ────────────────────────────────────────────────
              Expanded(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.black),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                'Sign Up',
                                style: AppTypography.h3Bold.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Full Name
                          _buildTextField(
                              hint: 'Full Name',
                              controller: _nameController,
                              keyboardType: TextInputType.name),
                          const SizedBox(height: 16),
                          // Age
                          _buildTextField(
                              hint: 'Age',
                              controller: _ageController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          // Phone number row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.black12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Text('🇮🇶',
                                        style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('+964',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  hint: '07xx xxxx xxx',
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Referral Code (Optional or Auto-applied)
                          _buildTextField(
                            hint: _detectedReferralCode != null
                                ? 'Referral Code: $_detectedReferralCode (Applied 🎉)'
                                : 'Referral Code (Optional)',
                            controller: _referralController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),
                          // Keyboard dismiss hint
                          GestureDetector(
                            onTap: _dismissKeyboard,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.keyboard_hide_rounded,
                                    size: 17, color: Colors.black38),
                                SizedBox(width: 5),
                                Text(
                                  'Tap anywhere to hide keyboard',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Next Button ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 30),
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  _dismissKeyboard();
                                  String rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
                                  if (rawPhone.startsWith('964')) rawPhone = rawPhone.substring(3);
                                  if (rawPhone.startsWith('0')) rawPhone = rawPhone.substring(1);
                                  final phone = '+964$rawPhone';
                                  if (_nameController.text.trim().isEmpty || rawPhone.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please fill in all fields.')),
                                    );
                                    return;
                                  }
                                  final success = await auth.registerPassenger(
                                    phone: phone,
                                    name: _nameController.text.trim(),
                                    age: _ageController.text.trim(),
                                  );
                                  if (!context.mounted) return;
                                  if (success) {
                                    await DeferredLinkService.clearPendingReferralCode();
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PassengerOtpScreen()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Registration failed. Please check your number.')),
                                    );
                                  }
                                },
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.black54),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.withOpacity(0.6)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
