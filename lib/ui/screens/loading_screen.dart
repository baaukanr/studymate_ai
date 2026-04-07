import 'dart:async';

import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.90,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(StudyMateRoutes.plan);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 64),
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: AppColors.neutral900,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'ИИ формирует твой план…',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Анализируем темы и создаем оптимальный график',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral500, fontSize: 16, height: 1.35),
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  minHeight: 12,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation(AppColors.neutral900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

