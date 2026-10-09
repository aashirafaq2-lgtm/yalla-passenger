import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_otp_screen.dart';
import 'passenger_signup_screen.dart';

class PassengerSignInScreen extends StatefulWidget {
  const PassengerSignInScreen({super.key});

  @override
  State<PassengerSignInScreen> createState() => _PassengerSignInScreenState();
}

class _PassengerSignInScreenState extends State<PassengerSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: AppColors.primaryOrange,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // White Card at top
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
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, color: Colors.black),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        Text(
                                          isArabic ? 'تسجيل الدخول' : 'Sign in',
                                          style: isArabic
                                              ? GoogleFonts.notoKufiArabic(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                )
                                              : AppTypography.h3Bold.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                        ),
                                        // Language Selector
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.offWhite,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.black12),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: isArabic ? 'ar' : 'en',
                                              isDense: true,
                                              icon: const Icon(Icons.language, size: 16, color: AppColors.primaryOrange),
                                              borderRadius: BorderRadius.circular(12),
                                              items: [
                                                DropdownMenuItem(
                                                  value: 'ar',
                                                  child: Text('العربية', style: GoogleFonts.notoKufiArabic(fontSize: 12, fontWeight: FontWeight.bold)),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'en',
                                                  child: Text('English', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                              onChanged: (lang) {
                                                if (lang != null) locale.setLocale(Locale(lang));
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  // Phone Input
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                                            Text('🇮🇶', style: TextStyle(fontSize: 20)),
                                            SizedBox(width: 8),
                                            Text('+964', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            hintText: '07xx xxxx xxx',
                                            hintStyle: const TextStyle(color: Colors.black38),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: const BorderSide(color: Colors.black12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: const BorderSide(color: Colors.black12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Tap to hide keyboard hint
                                  GestureDetector(
                                    onTap: _dismissKeyboard,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.keyboard_hide_rounded, size: 17, color: Colors.black38),
                                        SizedBox(width: 5),
                                        Text(
                                          'Tap anywhere to hide keyboard',
                                          style: TextStyle(fontSize: 12, color: Colors.black38),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Don't have account? Sign up
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have account? ",
                                        style: TextStyle(color: Colors.black54, fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const PassengerSignUpScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            color: AppColors.primaryOrange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Next Button
                        Padding(
                          padding: EdgeInsets.fromLTRB(32, 12, 32, isKeyboardOpen ? 12 : 30),
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
                                            String raw = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
                                            if (raw.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please enter your phone number.')),
                                              );
                                              return;
                                            }
                                            if (raw.startsWith('964')) raw = raw.substring(3);
                                            if (raw.startsWith('0')) raw = raw.substring(1);
                                            final phone = '+964$raw';
                                            final success = await auth.login(phone);
                                            if (!context.mounted) return;
                                            if (success) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const PassengerOtpScreen()),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Failed to send OTP. Please try again.')),
                                              );
                                            }
                                          },
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: AppColors.primaryOrange, strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'Next',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            },
          ),
        ),
      ),
    ));
  }
}
