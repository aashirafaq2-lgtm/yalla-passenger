import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentCode = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          localeProvider.tr('language'), 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLanguageOption(
              title: 'English',
              subtitle: 'English (US)',
              code: 'en',
              isSelected: currentCode == 'en',
              onTap: () => localeProvider.setLocale(const Locale('en')),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              title: 'العربية',
              subtitle: 'Arabic (Iraq)',
              code: 'ar',
              isSelected: currentCode == 'ar',
              onTap: () => localeProvider.setLocale(const Locale('ar')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.black12, 
            width: isSelected ? 2 : 1
          ),
          boxShadow: [
            if (isSelected) 
              BoxShadow(color: AppColors.primaryOrange.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: Colors.black,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            if (isSelected) 
              const Icon(Icons.check_circle, color: AppColors.primaryOrange, size: 28)
            else
              const Icon(Icons.circle_outlined, color: Colors.black26, size: 28),
          ],
        ),
      ),
    );
  }
}
