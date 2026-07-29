import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/premium_button.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.check_circle, color: AppColors.success, size: 80),
              const SizedBox(height: 24),
              Text('Hope you enjoyed your ride!', style: AppTypography.h2Bold.copyWith(fontSize: 28), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Rate your trip with Ahmed', style: TextStyle(color: Colors.black45)),
              const SizedBox(height: 48),
              
              // Big Price Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    const Text('Final Fare', style: TextStyle(color: Colors.black38, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('IQD 14,000', style: AppTypography.h1Black.copyWith(fontSize: 40)),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              // Star Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.star_border, color: AppColors.primaryOrange, size: 40),
                  );
                }),
              ),
              
              const Spacer(),
              
              PremiumButton(
                label: 'Submit Rating',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                color: Colors.black,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
