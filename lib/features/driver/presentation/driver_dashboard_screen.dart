import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background "Map" with Neural overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              image: DecorationImage(
                image: AssetImage('assets/images/mesh_gradient.png'), // Should be a dark abstract mesh
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
          ),
          
          // Floating Top Stats
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildFloatingStat('4.9 ★', 'Rating'),
                  const SizedBox(width: 12),
                  _buildFloatingStat('IQD 85k', 'Balance'),
                  const Spacer(),
                  FadeInRight(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                      child: const Icon(Icons.help_outline, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Draggable Dashboard Content
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10)),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Handlebar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Status Engine
                    _buildPremiumStatusToggle(),
                    
                    const SizedBox(height: 40),
                    Text('DRIVER PORTAL', style: AppTypography.h3Bold.copyWith(letterSpacing: 2, fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 16),
                    
                    // Feature List
                    _buildDashboardCard('Available Trips', 'assets/images/trips.png', context, badge: 'NEW', delay: 200),
                    _buildDashboardCard('My Schedule', 'assets/images/schedule.png', context, delay: 400),
                    _buildDashboardCard('Cargo & Parcels', 'assets/images/parcels.png', context, delay: 600),
                    _buildDashboardCard('Regional Booking', 'assets/images/outside.png', context, badge: 'HOT', delay: 800),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingStat(String value, String label) {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: MediaQuery.sizeOf(context).width * 0.04)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isOnline ? Colors.green[600] : Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (_isOnline ? Colors.green : Colors.black).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (_isOnline)
              Positioned.fill(
                child: FadeIn(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isOnline ? Icons.power_settings_new : Icons.no_crash, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    _isOnline ? 'ACTIVE & ONLINE' : 'GO ONLINE',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String imagePath, BuildContext context, {String? badge, int delay = 0}) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [
              Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.4), blurRadius: 10)],
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ),
              Positioned(
                bottom: 24,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Text('TAP TO OPEN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
