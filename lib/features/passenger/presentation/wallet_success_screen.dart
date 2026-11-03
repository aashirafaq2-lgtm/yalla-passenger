import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import 'passenger_main_screen.dart';

class WalletSuccessScreen extends StatelessWidget {
  final num? amount;
  const WalletSuccessScreen({super.key, this.amount});

  String _formatAmount(num val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;
    final size = MediaQuery.sizeOf(context);

    final displayAmount = amount != null && amount! > 0
        ? '${_formatAmount(amount!)} ${isArabic ? "\u062f.\u0639" : "IQD"}'
        : (isArabic ? '\u0627\u0644\u0631\u0635\u064a\u062f' : 'balance');

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            // White Card at top
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                height: size.height * 0.75,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      isArabic
                          ? '\u062a\u0645\u062a \u0625\u0636\u0627\u0641\u0629 \u0628\u0637\u0627\u0642\u062a\u0643 \u0628\u0646\u062c\u0627\u062d\n\u062a\u0645\u062a \u0625\u0636\u0627\u0641\u0629 $displayAmount\n\u0625\u0644\u0649 \u0645\u062d\u0641\u0638\u062a\u0643'
                          : 'Your code card has been\nsuccessfully added $displayAmount\nto your wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.4,
                        fontFamily: isArabic ? 'NotoKufiArabic' : null,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Success Checkmark
                    ZoomIn(
                      duration: const Duration(seconds: 1),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryOrange, width: 6),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 80,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic ? '\u0634\u0643\u0631\u0627\u064b \u0644\u0627\u0633\u062a\u062e\u062f\u0627\u0645\u0643 ' : 'Thank you for using with IQ ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                        ),
                        Text(
                          '\u064a\u064e\u0644\u0651\u0627',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 10,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
                          );
                        },
                        child: Text(
                          isArabic ? '\u0627\u0644\u0639\u0648\u062f\u0629 \u0644\u0644\u0631\u0626\u064a\u0633\u064a\u0629' : 'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: isArabic ? 'NotoKufiArabic' : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
