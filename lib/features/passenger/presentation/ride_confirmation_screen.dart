import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/premium_button.dart';
import 'searching_driver_screen.dart';
import 'payment_method_screen.dart';

class RideConfirmationScreen extends StatefulWidget {
  final String serviceType;
  const RideConfirmationScreen({super.key, required this.serviceType});

  @override
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> {
  String _selectedPayment = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Confirm ${widget.serviceType}', style: AppTypography.h2Bold),
              const Icon(Icons.info_outline, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 24),
          
          // Fare Details
          _buildDetailRow('Estimated Fare', 'IQD 12,500', isBold: true),
          const SizedBox(height: 12),
          _buildDetailRow('Distance', '5.4 km'),
          const SizedBox(height: 12),
          _buildDetailRow('Time', '12 mins'),
          
          const Divider(height: 48, color: Colors.black12),
          
          // Payment Method Selector
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.primaryOrange),
              const SizedBox(width: 12),
              Text(_selectedPayment, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
                },
                child: const Text('Change', style: TextStyle(color: AppColors.primaryOrange)),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          PremiumButton(
            label: 'Confirm with Yalla',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SearchingDriverScreen())
              );
            },
            color: AppColors.primaryOrange,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 20 : 16,
          )
        ),
      ],
    );
  }
}
