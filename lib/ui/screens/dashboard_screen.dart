import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Привет, Ернур! 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Готов продолжить подготовку?',
              style: TextStyle(color: AppColors.neutral500, fontSize: 16),
            ),
            const SizedBox(height: 18),
            _Card(
              title: 'Инфо о проекте',
              child: const Text(
                'StudyMate AI — MVP‑приложение, которое помогает студентам быстро получить персональный план подготовки к экзамену на основе предмета, даты и списка тем.',
                style: TextStyle(color: AppColors.neutral500, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              title: 'Ближайший экзамен',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.schedule, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Математический анализ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'До экзамена: 5 дней',
                    style: TextStyle(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: 0.65,
                      backgroundColor: AppColors.neutral200,
                      valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('65%', style: TextStyle(color: AppColors.neutral500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Создать новый план',
              icon: Icons.arrow_forward,
              helperText: 'ИИ поможет структурировать обучение',
              onPressed: () => Navigator.of(context).pushNamed(StudyMateRoutes.createPlan),
            ),
            const SizedBox(height: 18),
            const Text(
              'Последние материалы',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _MiniMaterialCard(
              title: 'Производные функций',
              subtitle: 'Математический анализ',
              progress: 0.35,
            ),
            const SizedBox(height: 10),
            _MiniMaterialCard(
              title: 'Интегралы',
              subtitle: 'Математический анализ',
              progress: 0.15,
            ),
            const SizedBox(height: 10),
            _MiniMaterialCard(
              title: 'Пределы',
              subtitle: 'Математический анализ',
              progress: 0.60,
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MiniMaterialCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;

  const _MiniMaterialCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.neutral500)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppColors.neutral200,
              valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}%', style: const TextStyle(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}

