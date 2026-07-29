import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'iq_brand',
                    child: Text('Yalla', style: AppTypography.h1Black.copyWith(fontSize: MediaQuery.sizeOf(context).width * 0.12)),
                  ),
                  const SizedBox(width: 12),
                  Hero(
                    tag: 'arabic_brand',
                    child: Text('يَلَّا', style: AppTypography.h1White.copyWith(fontSize: MediaQuery.sizeOf(context).width * 0.1)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FadeIn(
                duration: const Duration(seconds: 1),
                child: const Text(
                  'PREMIUM MOBILITY SERVER',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 4,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Selection Cards
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildRoleCard(
                          title: 'Passenger',
                          subtitle: 'Request a ride and reach your destination safely.',
                          icon: Icons.person_outline,
                          isDark: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen(role: 'passenger')),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildRoleCard(
                          title: 'Driver Portal',
                          subtitle: 'Join our elite fleet and earn on your schedule.',
                          icon: Icons.directions_car_outlined,
                          isDark: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen(role: 'driver')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Admin Entry (New)
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen(role: 'admin')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'SYSTEM ADMINISTRATION',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.offWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.h2Bold.copyWith(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
