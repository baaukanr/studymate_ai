import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/study_remote.dart';
import '../../data/study_store.dart';
import '../routes.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF22D3EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 68, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'StudyMate AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Твой умный помощник в подготовке к экзамену',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFEBF4FF),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
