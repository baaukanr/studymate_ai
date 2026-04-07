import 'package:flutter/material.dart';

import '../theme.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои экзамены')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              'Отслеживай прогресс подготовки',
              style: TextStyle(color: AppColors.neutral500, fontSize: 16),
            ),
            SizedBox(height: 16),
            _ExamCard(
              subject: 'Математический анализ',
              daysLeft: 5,
              progress: 0.65,
            ),
            SizedBox(height: 12),
            _ExamCard(
              subject: 'Физика',
              daysLeft: 12,
              progress: 0.40,
            ),
            SizedBox(height: 12),
            _ExamCard(
              subject: 'История',
              daysLeft: 2,
              progress: 0.85,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String subject;
  final int daysLeft;
  final double progress;

  const _ExamCard({
    Key? key,
    required this.subject,
    required this.daysLeft,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final done = progress >= 0.8;
    final barColor = done ? AppColors.green600 : AppColors.neutral900;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (done) const Icon(Icons.check_circle, color: AppColors.green600),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'До экзамена: $daysLeft дней',
            style: const TextStyle(color: AppColors.neutral500),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}%', style: const TextStyle(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}

