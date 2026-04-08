import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/plan_service.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  String? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.90,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final request = args is PlanRequest ? args : PlanService.pendingRequest;
    if (request == null) {
      setState(() => _error = 'Не переданы данные для генерации плана');
      return;
    }
    _generate(request);
  }

  Future<void> _generate(PlanRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    PlanService.pendingRequest = null;
    final err = await PlanService.generatePlan(request);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final examId = PlanService.pendingExamId;
    final plan = PlanService.currentPlan;
    if (examId != null && plan != null) {
      StudyStore.instance.saveGeneratedPlan(examId: examId, plan: plan);
      PlanService.pendingExamId = null;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(StudyMateRoutes.plan);
  }

  @override
  void dispose() {
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
                'Отправляем запрос к ИИ…',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Сервер формирует персональный план по вашим темам',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral500, fontSize: 16, height: 1.35),
              ),
              const SizedBox(height: 22),
              if (_error == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 12,
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation(AppColors.neutral900),
                  ),
                ),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
