import 'package:flutter/material.dart';

class AppColors {
  static const neutral50 = Color(0xFFF8F8F8);
  /// Фон приложения — чуть контрастнее белого.
  static const surface = Color(0xFFF3F3F3);
  static const neutral200 = Color(0xFFE6E6E6);
  static const borderSubtle = Color(0xFFD4D4D4);
  static const neutral500 = Color(0xFF737373);
  static const textSecondary = Color(0xFF525252);
  static const neutral900 = Color(0xFF0A0A0A);
  static const white = Color(0xFFFFFFFF);
  static const green600 = Color(0xFF16A34A);
  static const red600 = Color(0xFFDC2626);
}

class AppRadii {
  static const r16 = BorderRadius.all(Radius.circular(16));
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
  static const cardSoft = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}

