import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Language', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLanguageOption('English', 'en'),
            const SizedBox(height: 16),
            _buildLanguageOption('العربية', 'ar'),
            const SizedBox(height: 16),
            _buildLanguageOption('Kurdî', 'ku'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String locale) {
    bool isSelected = _selectedLanguage == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppColors.primaryOrange : Colors.black12),
          boxShadow: [
            if (isSelected) BoxShadow(color: AppColors.primaryOrange.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryOrange),
          ],
        ),
      ),
    );
  }
}
