import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/study_remote.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () async {
      final ok = await AuthService.isAuthorized();
      if (!mounted) return;
      if (ok) {
        final snap = await fetchStudySnapshot();
        if (snap != null) await StudyStore.instance.applyServerPayload(snap);
        if (!mounted) return;
      }
      Navigator.of(context).pushReplacementNamed(
        ok ? StudyMateRoutes.tabs : StudyMateRoutes.login,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.auto_awesome, size: 56, color: Colors.white),
              SizedBox(height: 14),
              Text(
                'StudyMate AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Твой умный помощник',
                style: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
