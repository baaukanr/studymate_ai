import 'package:flutter/material.dart';

import '../../data/study_models.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StudyStore.instance;
    final list = List<ExamEntry>.from(store.exams)
      ..sort((a, b) {
        final da = StudyStore.parseUserDate(a.examDate);
        final db = StudyStore.parseUserDate(b.examDate);
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Экзамены'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Экзамен — календарная дата и предмет. План (шаги день 1, 2…) создаётся отдельно и привязывается к экзамену.',
              style: TextStyle(color: AppColors.neutral500, fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Добавить экзамен и план',
              icon: Icons.add,
              onPressed: () => Navigator.of(context).pushNamed(StudyMateRoutes.createExam),
            ),
            const SizedBox(height: 20),
            if (list.isEmpty)
              const Text(
                'Пока нет экзаменов.',
                style: TextStyle(color: AppColors.neutral500),
              )
            else
              ...list.map((e) {
                final d = StudyStore.calendarDaysUntilExam(e.examDate);
                final plan = store.latestPlanForExam(e.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
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
                        Text(
                          e.subject,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Дата экзамена: ${e.examDate}',
                          style: const TextStyle(color: AppColors.neutral500),
                        ),
                        if (d != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            d >= 0
                                ? 'До экзамена: $d календ. дн.'
                                : 'Экзамен прошёл',
                            style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                          ),
                        ],
                        if (plan != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'План: ${plan.daysJson.length} шагов, ${StudyStore.formatPlanDurationRu(plan.totalPlanMinutes)}',
                            style: const TextStyle(color: AppColors.neutral500, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () {
                              StudyStore.instance.applyPlanToMemory(plan);
                              Navigator.of(context).pushNamed(StudyMateRoutes.plan);
                            },
                            child: const Text('Открыть план'),
                          ),
                        ] else ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed(
                              StudyMateRoutes.createPlan,
                              arguments: e,
                            ),
                            child: const Text('Создать план подготовки'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
