import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import 'parcel_success_screen.dart';

class ParcelSummaryScreen extends StatelessWidget {
  const ParcelSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              FadeInDown(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Logo
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Yalla ',
                      style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -2),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'يَلَّا',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 34,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Sender Card
              _buildSummaryCard(
                title: 'Sender',
                details: {
                  'Name': 'Yasser',
                  'Phone number': '0770-123-1234',
                  'governorate': 'Kirkuk',
                  'Region': 'Baghdad road',
                  'Date & time': '2026-02-17 2:00 AM',
                },
                index: 0,
              ),
              const SizedBox(height: 20),

              // Recipient Card
              _buildSummaryCard(
                title: 'Recipient',
                details: {
                  'Name': 'Ahmed',
                  'Phone number': '0770-123-1234',
                  'governorate': 'Baghdad',
                  'Region': 'Al-Adhamiyah',
                  'Date & time': '2026-02-17 2:00 AM',
                },
                index: 1,
              ),
              const SizedBox(height: 20),

              // Price Card
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Delivery price', '10,000 IQD'),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment method', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
                          Row(
                            children: [
                               _buildCompactCardIcon('assets/images/cash_icon.png'),
                               const SizedBox(width: 8),
                               _buildCompactCardIcon('assets/images/mastercard_icon.png'),
                               const SizedBox(width: 8),
                               _buildCompactCardIcon('assets/images/visa_icon.png'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      _buildDetailRow('Total', '10,000 IQD', isTotal: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Create Button
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: () async {
                      try {
                        // Call backend API endpoint for parcel creation
                        await ApiService().requestParcel({
                          'type': 'PARCEL',
                          'status': 'PENDING',
                          'sender': 'Yasser',
                          'recipient': 'Ahmed',
                        }, 'mock_token');
                      } catch (_) {}
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelSuccessScreen()));
                      }
                    },
                    child: const Text('Create mail Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required Map<String, String> details, required int index}) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 25),
            ...details.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                      Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 16 : 14,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: isTotal ? Colors.black : Colors.black54,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 16 : 14,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          color: Colors.black,
        )),
      ],
    );
  }

  Widget _buildCompactCardIcon(String asset) {
    return Container(
      width: 35,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
      child: Image.asset(asset, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.credit_card, size: 12)),
    );
  }
}
