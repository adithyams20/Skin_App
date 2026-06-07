import 'package:flutter/material.dart';

class AppColors {

  static const primary = Color(0xFF22C55E);
  static const secondary = Color(0xFF16A34A);

  static const background = Color(0xFFF6F7FB);
  static const card = Colors.white;

  static const textDark = Color(0xFF1F2937);
  static const textLight = Color(0xFF6B7280);

  static const border = Color(0xFFE5E7EB);

  static const danger = Colors.red;

  // 🔥 AQUA GRADIENT (MAIN THEME)
  static const aquaGradient = LinearGradient(
    colors: [
      Color(0xFF00C9A7),
      Color(0xFF22C55E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // fallback gradient
  static const primaryGradient = aquaGradient;
}