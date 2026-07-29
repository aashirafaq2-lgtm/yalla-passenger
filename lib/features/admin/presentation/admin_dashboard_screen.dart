import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text('Platform Overview', style: AppTypography.h2Bold.copyWith(fontSize: 32, letterSpacing: -1)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Grid
                  _buildStatsGrid(),
                  
                  const SizedBox(height: 40),
                  
                  // Fleet Integrity Card
                  _buildIntegrityCard(),
                  
                  const SizedBox(height: 40),
                  
                  Text('Recent Fleet Activity', style: AppTypography.h3Bold.copyWith(fontSize: 24)),
                  const SizedBox(height: 16),
                  
                  // Activity List
                  _buildActivityList(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: const Color(0xFF050505),
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.shieldHalved, color: AppColors.primaryOrange, size: 20),
            const SizedBox(width: 12),
            Text('IQ ADMIN', style: AppTypography.h3Bold.copyWith(color: Colors.white, letterSpacing: -1)),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard('Drivers', '452', FontAwesomeIcons.car, Colors.blue),
        _buildStatCard('Passengers', '1.2k', FontAwesomeIcons.users, Colors.purple),
        _buildStatCard('Live Rides', '84', FontAwesomeIcons.bolt, Colors.orange),
        _buildStatCard('Revenue', '1.2M', FontAwesomeIcons.wallet, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrityCard() {
    return FadeInLeft(
      child: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          borderRadius: BorderRadius.circular(35),
          image: const DecorationImage(
            image: AssetImage('assets/images/mesh_gradient.png'), // Placeholder or color pulse
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            const Icon(FontAwesomeIcons.circleCheck, color: Colors.greenAccent, size: 48),
            const SizedBox(height: 24),
            Text('System Integrity: Optimized', style: AppTypography.h3Bold.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Real-time synchronization active across all regions.', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('RUN FLEET AUDIT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'user': 'Ali Hassan', 'action': 'Withdrawal initiated', 'status': 'Pending'},
      {'user': 'Zaid Karim', 'action': 'New Driver Verified', 'status': 'Success'},
      {'user': 'Omar Jaffar', 'action': 'Ride dispute resolved', 'status': 'Closed'},
    ];
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final act = activities[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person, size: 18)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(act['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(act['action']!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: act['status'] == 'Success' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(act['status']!, style: TextStyle(
                  color: act['status'] == 'Success' ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}
