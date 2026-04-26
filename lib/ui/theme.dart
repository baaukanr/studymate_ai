import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFECF2FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF4F8FF);
  static const surfaceStrong = Color(0xFFD9E6FF);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral200 = Color(0xFFBBC8E0);
  static const borderSubtle = Color(0xFFD7E0F3);
  static const textSecondary = Color(0xFF60738D);
  static const neutral500 = Color(0xFF64748B);
  static const textPrimary = Color(0xFF111827);
  static const neutral900 = Color(0xFF111827);
  static const primary = Color(0xFF5B5BFF);
  static const accent = Color(0xFF22D3EE);
  static const accentWarm = Color(0xFF8B5CF6);
  static const green600 = Color(0xFF16A34A);
  static const red600 = Color(0xFFEF4444);
  static const white = Color(0xFFFFFFFF);
  static const shadow = Color(0x240F172A);
}

class AppGradients {
  static const authBackground = LinearGradient(
    colors: [Color(0xFFEEF4FF), Color(0xFFDCE8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const hero = LinearGradient(
    colors: [Color(0xFF5B5BFF), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const card = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const button = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppRadii {
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r20 = BorderRadius.all(Radius.circular(20));
  static const r24 = BorderRadius.all(Radius.circular(24));
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x220F172A),
      blurRadius: 24,
      offset: Offset(0, 14),
    ),
  ];

  static const cardSoft = [
    BoxShadow(
      color: Color(0x160F172A),
      blurRadius: 34,
      offset: Offset(0, 18),
    ),
  ];
}

