import 'package:flutter/material.dart';

class TColors {
  // App theme colors
  static const Color primary = Color(0xFF01655C);
  static const Color secondary = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color light = Color(0xFFF5F5F5);
  static const Color dark = Color(0xFF000000);
  static const Color primaryBackground = Color(0xFFF5F5F5);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF5F5F5);
  static Color darkContainer = TColors.white.withValues(alpha: 0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF01655C);
  static const Color buttonSecondary = Color(0xFF97BC62);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF01655C);

  // Neutral Shades
  static const Color black = Color(0xFF000000);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFF5F5F5);
  static const Color iconPrimaryLight =
      Color(0xFF01655C); // Theme Nightingale Gray 80
  static const Color disabledTextLight = Color(0xFFD1D5DB);
}
