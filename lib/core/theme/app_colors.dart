import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFFF9F45);
  static const Color primaryDark = Color(0xFFE66C00);
  static const Color accentBlue = Color(0xFF0EA5E9);
  
  // Luxury Palette
  static const Color surfaceBlack = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color offWhite = Color(0xFFF8FAFC);
  
  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryOrange,
      Color(0xFFFF8C20),
      primaryDark,
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x11FFFFFF),
    ],
  );
  
  // States
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}
