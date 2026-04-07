import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/phone_frame.dart';
import 'ui/routes.dart';
import 'ui/theme.dart';

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.neutral50,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final theme = base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.neutral900),
        titleTextStyle: TextStyle(
          color: AppColors.neutral900,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: AppColors.neutral900,
          onPrimary: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        hintStyle: const TextStyle(color: AppColors.neutral500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutral900, width: 1),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate AI',
      theme: theme,
      onGenerateRoute: StudyMateRoutes.onGenerateRoute,
      initialRoute: StudyMateRoutes.splash,
      builder: (context, child) => PhoneFrame(child: child ?? const SizedBox()),
    );
  }
}

