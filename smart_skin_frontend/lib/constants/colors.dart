import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPink    = Color(0xFFF1ABB9);
  static const Color deepPink       = Color(0xFFE08499);
  static const Color backgroundLight = Color(0xFFFFF9FB);
  static const Color textDark       = Color(0xFF333333);
  static const Color textGrey       = Color(0xFF888888);
  static const Color accentBlue     = Color(0xFF91C4EA);
  static const Color accentLavender = Color(0xFFC7CCF1);
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color success        = Color(0xFF4CAF50);
  static const Color warning        = Color(0xFFFF9800);
  static const Color error          = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE5B3BC), Color(0xFFC7CCF1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
