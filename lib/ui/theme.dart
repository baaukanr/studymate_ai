import 'package:flutter/material.dart';

class AppColors {
  static const neutral50 = Color(0xFFF8F8F8);
  static const neutral200 = Color(0xFFE6E6E6);
  static const neutral500 = Color(0xFF7A7A7A);
  static const neutral900 = Color(0xFF111111);
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
}

