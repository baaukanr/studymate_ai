import 'package:flutter/material.dart';

import '../../data/plan_service.dart';
import '../../data/plan_session_tracker.dart';
import '../../data/study_models.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({Key? key}) : super(key: key);

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  void initState() {
    super.initState();
    StudyStore.instance.addListener(_onStore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = PlanService.currentPlanId;
      if (id != null) {
        PlanSessionTracker.instance.startPlanList(id);
      }
    });
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    StudyStore.instance.removeListener(_onStore);
    PlanSessionTracker.instance.stop();
    super.dispose();
  }

  void _done(BuildContext context) {
    PlanSessionTracker.instance.stop();
    Navigator.of(context).popUntil((route) {
      return route.settings.name == StudyMateRoutes.tabs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = PlanService.currentPlan;
    final planId = PlanService.currentPlanId;
    final items = plan?.days ?? const <PlanDay>[];
    final saved = planId != null ? StudyStore.instance.getPlan(planId) : null;
    final totalMin = saved?.totalPlanMinutes ??
        (plan == null ? 0 : plan.days.fold<int>(0, (a, d) => a + d.minutes));
    final engaged = saved?.planEngagementSeconds ?? 0;
    final targetSec = totalMin * 60;
    final progress = targetSec > 0 ? (engaged / targetSec).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).round();

    ExamEntry? examMatch;
    if (plan != null && planId != null) {
      final sp = StudyStore.instance.getPlan(planId);
      if (sp != null) {
        examMatch = StudyStore.instance.getExam(sp.examId);
      }
    }

    final daysToExam = examMatch != null
        ? StudyStore.calendarDaysUntilExam(examMatch.examDate)
        : (plan != null ? StudyStore.calendarDaysUntilExam(plan.examDate) : null);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            PlanSessionTracker.instance.stop();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Мой план подготовки'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  if (plan != null) ...[
                    Text(
                      plan.subject,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Экзамен: ${plan.examDate}',
                      style: const TextStyle(color: AppColors.neutral500, fontSize: 15),
                    ),
                    if (daysToExam != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        daysToExam >= 0
                            ? 'До экзамена: $daysToExam ${_daysWord(daysToExam)} (календарь)'
                            : 'Экзамен прошёл (${-daysToExam} дн. назад)',
                        style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'План: ${items.length} шагов • рассчитан на ${StudyStore.formatPlanDurationRu(totalMin)}',
                      style: const TextStyle(color: AppColors.neutral500, fontSize: 14, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Шаги «день 1, день 2…» — порядок тем в подготовке, не календарные дни.',
                      style: TextStyle(color: AppColors.neutral500, fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Прогресс по времени',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: AppColors.neutral200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Учитывается время с открытым планом и темами (обновляется каждую секунду).',
                      style: TextStyle(color: AppColors.neutral500.withOpacity(0.9), fontSize: 12),
                    ),
                  ] else
                    const Text(
                      'План не найден',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                  if (PlanService.lastPlanWasLocalFallback) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDBA74)),
                      ),
                      child: const Text(
                        'ИИ-план не сгенерирован: приложение не достучалось до сервера '
                        '(или запрос оборвался). Показан запасной план по вашим темам.\n\n'
                        'Что сделать:\n'
                        '• Запустите backend: папка server → npm install → npm start (порт 8787).\n'
                        '• Задайте AI ключ: set OPENROUTER_API_KEY=sk-or-v1-... (или NVIDIA_API_KEY при AI_PROVIDER=nvidia) перед npm start.\n'
                        '• С телефона/эмулятора localhost не виден — укажите IP вашего ПК в настройках или --dart-define.',
                        style: TextStyle(
                          color: Color(0xFF9A3412),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const Text(
                      'Создайте план через главную.',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                  ...items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pushNamed(
                          StudyMateRoutes.topic,
                          arguments: it,
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
                                      'Шаг плана · день ${it.day}',
                                      style: const TextStyle(
                                        color: AppColors.neutral500,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
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
                                          '${it.minutes} мин в плане',
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
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: PrimaryButton(
                label: 'Готово',
                onPressed: plan == null ? null : () => _done(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _daysWord(int n) {
    final r = n % 10;
    final rr = n % 100;
    if (r == 1 && rr != 11) return 'календарный день';
    if (r >= 2 && r <= 4 && (rr < 10 || rr > 20)) return 'календарных дня';
    return 'календарных дней';
  }
}
