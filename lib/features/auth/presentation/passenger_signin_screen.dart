import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
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
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Column(
        children: [
          // White Card at top
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: double.infinity,
              height: size.height * 0.75,
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
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Sign in',
                        style: AppTypography.h3Bold.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  // Phone Input Row
                  Row(
                    children: [
                      // Country Picker (Mock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        child: Row(
                          children: [
                            Image.network(
                              'https://flagcdn.com/w40/iq.png',
                              width: 24,
                              errorBuilder: (_, __, ___) => const Icon(Icons.flag),
                            ),
                            const SizedBox(width: 8),
                            const Text('+964', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone Number Field
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '07xx xxxx xxx',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Link to Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have account? ", style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PassengerSignUpScreen()),
                          );
                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
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
            child: Center(
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: auth.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _buildButton(
                            context, 
                            'Next', 
                            () async {
                              final success = await auth.login('+964${_phoneController.text}');
                              if (success) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PassengerOtpScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Login failed. Please check your number.')),
                                );
                              }
                            },
                          ),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onTap) {
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
