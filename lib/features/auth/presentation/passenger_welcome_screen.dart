import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'passenger_signin_screen.dart';
import 'passenger_signup_screen.dart';

class PassengerWelcomeScreen extends StatelessWidget {
  const PassengerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Column(
        children: [
          // White Card at top
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: double.infinity,
              height: size.height * 0.75,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Sign in',
                    style: AppTypography.h3Bold.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const Spacer(),
                  // Brand Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'iq_brand',
                        child: Text(
                          'Yalla',
                          style: AppTypography.h1Black.copyWith(
                            fontSize: size.width * 0.18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Hero(
                        tag: 'arabic_brand',
                        child: Text(
                          'يَلَّا',
                          style: AppTypography.h1White.copyWith(
                            fontSize: size.width * 0.15,
                            color: AppColors.primaryOrange,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sign In Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildButton(
                      context,
                      'Sign In',
                      Colors.white,
                      Colors.black,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PassengerSignInScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Create Account Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildButton(
                      context,
                      'Create Account',
                      AppColors.primaryOrange,
                      Colors.white,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PassengerSignUpScreen()),
                      ),
                      isBordered: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, 
    String text, 
    Color bgColor, 
    Color textColor,
    VoidCallback onTap,
    {bool isBordered = false}
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: isBordered ? 0 : 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: isBordered ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
