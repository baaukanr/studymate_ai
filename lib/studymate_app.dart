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
      scaffoldBackgroundColor: AppColors.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dividerColor: AppColors.borderSubtle,
    );

    final interText = GoogleFonts.interTextTheme(base.textTheme);
    final appBarTitle = interText.headline6?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ) ??
        const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        );

    final theme = base.copyWith(
      textTheme: interText,
      // Flutter 2.x: color + brightness + textTheme.headline6 для заголовка AppBar
      appBarTheme: AppBarTheme(
        color: AppColors.surface,
        brightness: Brightness.light,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: interText.copyWith(headline6: appBarTitle),
        titleTextStyle: appBarTitle,
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
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.neutral500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neutral900, width: 1.2),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        margin: EdgeInsets.zero,
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

