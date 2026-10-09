import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/locale_provider.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'passenger' or 'driver'
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradient,
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Header with Back Button and Language Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Hero(
                      tag: '${widget.role}_login_tag',
                      child: Text(
                        widget.role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Language Toggle Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: isArabic ? 'ar' : 'en',
                          dropdownColor: const Color(0xFF1E1E20),
                          isDense: true,
                          icon: const Icon(Icons.language, size: 16, color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية', style: GoogleFonts.notoKufiArabic(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
              ),
              
              const Spacer(),
              
              // Authentication Card (Glass Effect)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: MediaQuery.sizeOf(context).height * 0.05),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isArabic ? 'مرحباً بك في يَلَّا' : 'Welcome to Yalla',
                        style: isArabic 
                            ? GoogleFonts.notoKufiArabic(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF1C1C1E))
                            : AppTypography.h2Bold.copyWith(fontSize: MediaQuery.sizeOf(context).width * 0.08),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isArabic ? 'أدخل رقم هاتفك للمتابعة' : 'Enter your phone number to continue.',
                        style: isArabic 
                            ? GoogleFonts.notoKufiArabic(color: Colors.black54, fontSize: 14)
                            : const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      
                      // Phone Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Row(
                          children: [
                            const Text(
                              '+964',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 1, height: 24, color: Colors.black12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  hintText: '770 000 0000',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primaryOrange.withOpacity(0.5),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtpVerificationScreen(role: widget.role),
                              ),
                            );
                          },
                          child: Text(
                            isArabic ? 'إرسال رمز التحقق' : 'Send OTP Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          isArabic 
                              ? 'بمتابعتك، فإنك توافق على شروط الخدمة وسياسة الخصوصية'
                              : 'By continuing, you agree to our Terms of Service',
                          style: TextStyle(
                            color: Colors.black38, 
                            fontSize: 12,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
