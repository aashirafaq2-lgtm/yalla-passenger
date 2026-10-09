import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'parcel_success_screen.dart';

class ParcelSummaryScreen extends StatelessWidget {
  const ParcelSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

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
                        icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          isArabic ? 'ملخص الشحنة' : 'Parcel Summary',
                          style: TextStyle(
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            fontSize: 20, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
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
                title: isArabic ? 'بيانات المرسل' : 'Sender',
                details: isArabic ? {
                  'الاسم': 'المرسل',
                  'رقم الهاتف': '0770-123-1234',
                  'المحافظة': 'كركوك',
                  'المنطقة': 'طريق بغداد',
                  'التاريخ والوقت': '2026-02-17 2:00 ص',
                } : {
                  'Name': 'Sender',
                  'Phone number': '0770-123-1234',
                  'governorate': 'Kirkuk',
                  'Region': 'Baghdad road',
                  'Date & time': '2026-02-17 2:00 AM',
                },
                index: 0,
                isArabic: isArabic,
              ),
              const SizedBox(height: 20),

              // Recipient Card
              _buildSummaryCard(
                title: isArabic ? 'بيانات المستلم' : 'Recipient',
                details: isArabic ? {
                  'الاسم': 'أحمد',
                  'رقم الهاتف': '0770-123-1234',
                  'المحافظة': 'بغداد',
                  'المنطقة': 'الأعظمية',
                  'التاريخ والوقت': '2026-02-17 2:00 ص',
                } : {
                  'Name': 'Ahmed',
                  'Phone number': '0770-123-1234',
                  'governorate': 'Baghdad',
                  'Region': 'Al-Adhamiyah',
                  'Date & time': '2026-02-17 2:00 AM',
                },
                index: 1,
                isArabic: isArabic,
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
                      _buildDetailRow(
                        isArabic ? 'سعر التوصيل' : 'Delivery price', 
                        isArabic ? '١٠,٠٠٠ د.ع' : '10,000 IQD'
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'طريقة الدفع' : 'Payment method', 
                            style: TextStyle(
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                              fontWeight: FontWeight.w500, 
                              color: Colors.black54
                            )
                          ),
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
                      _buildDetailRow(
                        isArabic ? 'الإجمالي' : 'Total', 
                        isArabic ? '١٠,٠٠٠ د.ع' : '10,000 IQD', 
                        isTotal: true
                      ),
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
                    child: Text(
                      isArabic ? 'إرسال طلب الشحنة' : 'Create mail Requests', 
                      style: TextStyle(
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        fontSize: 18, 
                        fontWeight: FontWeight.w900
                      )
                    ),
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

  Widget _buildSummaryCard({
    required String title, 
    required Map<String, String> details, 
    required int index,
    required bool isArabic,
  }) {
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
          crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontFamily: isArabic ? 'NotoKufiArabic' : null,
                fontSize: 20, 
                fontWeight: FontWeight.bold
              )
            ),
            const Divider(height: 25),
            ...details.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key, 
                        style: TextStyle(
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          color: Colors.black54, 
                          fontWeight: FontWeight.w500
                        )
                      ),
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
