import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'passenger_home_screen.dart';
import 'passenger_trips_screen.dart';
import 'passenger_profile_screen.dart';

class PassengerMainScreen extends StatefulWidget {
  const PassengerMainScreen({super.key});

  @override
  State<PassengerMainScreen> createState() => _PassengerMainScreenState();
}

class _PassengerMainScreenState extends State<PassengerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PassengerHomeScreen(),
    const PassengerTripsScreen(),
    const PassengerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        controller: _pageController,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primaryOrange.withOpacity(0.8),
            unselectedItemColor: Colors.black,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Colors.black,
            ),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 12),
                  child: Icon(
                    Icons.home_filled, 
                    size: 32, 
                    color: _selectedIndex == 0 ? AppColors.primaryOrange.withOpacity(0.8) : Colors.black,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 12),
                  child: Icon(
                    Icons.directions_car_filled, 
                    size: 32,
                    color: _selectedIndex == 1 ? AppColors.primaryOrange.withOpacity(0.8) : Colors.black,
                  ),
                ),
                label: 'My trips',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 12),
                  child: Icon(
                    Icons.person, 
                    size: 32,
                    color: _selectedIndex == 2 ? AppColors.primaryOrange.withOpacity(0.8) : Colors.black,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
