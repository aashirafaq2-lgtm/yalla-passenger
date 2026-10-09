import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? 'مركز الدعم' : 'Support Center',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: isArabic ? 'NotoKufiArabic' : null,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.support_agent_rounded, size: 80, color: AppColors.primaryOrange),
              const SizedBox(height: 20),
              Text(
                isArabic ? 'كيف يمكننا مساعدتك؟' : 'How can we help you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isArabic
                    ? 'يبدو أنك تواجه مشكلة في خدمتنا. نحن هنا للمساعدة.'
                    : 'It looks like you are experiencing problems with our service. We are here to help.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
              ),
              const SizedBox(height: 40),
              _buildContactCard(
                Icons.chat_bubble_outline,
                isArabic ? 'تحدث معنا' : 'Chat with us',
                isArabic ? 'متاح على مدار الساعة' : 'Active 24/7',
                isArabic,
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                Icons.email_outlined,
                isArabic ? 'راسلنا بالبريد' : 'Email us',
                'support@yalla.app',
                isArabic,
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                Icons.phone_outlined,
                isArabic ? 'اتصل بنا' : 'Call us',
                '+964 770 123 4567',
                isArabic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryOrange),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: isArabic ? 'NotoKufiArabic' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
