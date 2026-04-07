import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/primary_button.dart';

class TopicScreen extends StatelessWidget {
  final String topicTitle;

  const TopicScreen({Key? key, required this.topicTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Тема'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: const Text(
                'День 2 • Математический анализ',
                style: TextStyle(color: AppColors.neutral500, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              topicTitle,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.schedule, size: 16),
                SizedBox(width: 6),
                Text('45 мин', style: TextStyle(color: AppColors.neutral500)),
                SizedBox(width: 14),
                Icon(Icons.signal_cellular_alt, size: 16),
                SizedBox(width: 6),
                Text('Средний', style: TextStyle(color: AppColors.neutral500)),
              ],
            ),
            const SizedBox(height: 18),
            const _Section(
              title: 'Что такое производная?',
              body:
                  'Производная показывает, как быстро меняется функция в данный момент. '
                  'Это “мгновенная скорость изменения”.',
            ),
            const SizedBox(height: 12),
            const _Section(
              title: 'Основные правила',
              body: '1) (c)′ = 0\n2) (x^n)′ = n·x^(n−1)\n3) (f+g)′ = f′ + g′',
            ),
            const SizedBox(height: 12),
            const _Section(
              title: 'Примеры применения',
              body:
                  'Скорость и ускорение, оптимизация расходов, анализ графиков и предельных изменений.',
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Назад к плану',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({Key? key, required this.title, required this.body}) : super(key: key);

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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: AppColors.neutral500, height: 1.35)),
        ],
      ),
    );
  }
}

