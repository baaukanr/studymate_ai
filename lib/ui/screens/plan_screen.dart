import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      7,
      (i) => _PlanItem(
        day: i + 1,
        topic: i == 1 ? 'Производные функций' : 'Тема ${i + 1}',
        minutes: 45,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Мой план подготовки'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Математический анализ',
              style: TextStyle(color: AppColors.neutral500, fontSize: 16),
            ),
            const SizedBox(height: 14),
            ...items.map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pushNamed(
                    StudyMateRoutes.topic,
                    arguments: it.topic,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'День ${it.day}',
                                style: const TextStyle(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                it.topic,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${it.minutes} мин',
                                    style: const TextStyle(color: AppColors.neutral500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.neutral500),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanItem {
  final int day;
  final String topic;
  final int minutes;

  _PlanItem({required this.day, required this.topic, required this.minutes});
}

