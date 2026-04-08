import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/plan_service.dart' show PlanDay;
import '../../data/plan_session_tracker.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    StudyStore.instance.addListener(_onData);
    PlanSessionTracker.instance.addListener(_onData);
    _loadUser();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    StudyStore.instance.removeListener(_onData);
    PlanSessionTracker.instance.removeListener(_onData);
    super.dispose();
  }

  Future<void> _loadUser() async {
    final cached = await AuthService.getCachedUser();
    if (mounted) setState(() => _user = cached);
    final fresh = await AuthService.refreshCurrentUser();
    if (mounted && fresh != null) setState(() => _user = fresh);
  }

  int _minutesForTopic(String planId, String topic) {
    final p = StudyStore.instance.getPlan(planId);
    if (p == null) return 45;
    for (final m in p.daysJson) {
      if ((m['topic'] as String? ?? '') == topic) {
        return (m['minutes'] as num?)?.toInt() ?? 45;
      }
    }
    return 45;
  }

  @override
  Widget build(BuildContext context) {
    final firstName = (_user?.firstName.isNotEmpty ?? false) ? _user!.firstName : 'студент';
    final store = StudyStore.instance;
    final exam = store.nearestExam();
    final planEntry = exam != null ? store.latestPlanForExam(exam.id) : null;
    final daysLeft = exam != null ? StudyStore.calendarDaysUntilExam(exam.examDate) : null;

    double planProgress = 0;
    int pct = 0;
    if (planEntry != null && planEntry.totalPlanMinutes > 0) {
      planProgress = planEntry.readinessProgress(0);
      pct = (planProgress * 100).round();
    }

    final recent = store.recentMaterials.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Главная'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Привет, $firstName! 👋',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Календарные дни до экзамена и шаги плана (день 1, 2…) — разные вещи: первое от даты экзамена, второе от ИИ.',
              style: TextStyle(color: AppColors.neutral500, fontSize: 15, height: 1.35),
            ),
            const SizedBox(height: 18),
            if (exam != null) ...[
              Container(
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
                      exam.subject,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    if (daysLeft != null)
                      Text(
                        daysLeft >= 0
                            ? 'До экзамена: $daysLeft ${_calDays(daysLeft)}'
                            : 'Экзамен прошёл',
                        style: const TextStyle(color: AppColors.neutral500, fontSize: 15),
                      ),
                    if (planEntry != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Прогресс подготовки',
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
                          value: planProgress.clamp(0.0, 1.0),
                          backgroundColor: AppColors.neutral200,
                          valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'План на ${StudyStore.formatPlanDurationRu(planEntry.totalPlanMinutes)} · '
                        'учтено время с открытым планом и темами',
                        style: TextStyle(color: AppColors.neutral500.withOpacity(0.95), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            StudyStore.instance.applyPlanToMemory(planEntry);
                            Navigator.of(context).pushNamed(StudyMateRoutes.plan);
                          },
                          child: const Text('Открыть план'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Text(
                        'План подготовки ещё не создан для этого экзамена.',
                        style: TextStyle(color: AppColors.neutral500, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const Text(
                'Добавьте экзамен — затем список тем для ИИ.',
                style: TextStyle(color: AppColors.neutral500, fontSize: 15),
              ),
              const SizedBox(height: 16),
            ],
            Material(
              color: AppColors.neutral900,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).pushNamed(StudyMateRoutes.createExam),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Создать новый план',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'ИИ поможет структурировать обучение',
                              style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Последние материалы',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const Text(
                'Откройте темы из плана — они появятся здесь с прогрессом по времени.',
                style: TextStyle(color: AppColors.neutral500, fontSize: 14),
              )
            else
              ...recent.map((m) {
                final min = _minutesForTopic(m.planId, m.topic);
                final p = StudyStore.instance.getPlan(m.planId);
                final sec = p?.topicEngagementSeconds[m.topic] ?? 0;
                final prog = min > 0 ? (sec / (min * 60)).clamp(0.0, 1.0) : 0.0;
                final pPct = (prog * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final entry = StudyStore.instance.getPlan(m.planId);
                      if (entry == null) return;
                      StudyStore.instance.applyPlanToMemory(entry);
                      PlanDay? day;
                      for (final d in entry.daysJson) {
                        if ((d['topic'] as String? ?? '') == m.topic) {
                          day = PlanDay.fromJson(d);
                          break;
                        }
                      }
                      if (day != null) {
                        Navigator.of(context).pushNamed(StudyMateRoutes.topic, arguments: day);
                      }
                    },
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
                                  m.topic,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.subject,
                                  style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 52,
                            width: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: prog,
                                  strokeWidth: 4,
                                  backgroundColor: AppColors.neutral200,
                                  valueColor:
                                      const AlwaysStoppedAnimation(AppColors.neutral900),
                                ),
                                Text(
                                  '$pPct%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static String _calDays(int n) {
    final r = n % 10;
    final rr = n % 100;
    if (r == 1 && rr != 11) return 'календарный день';
    if (r >= 2 && r <= 4 && (rr < 10 || rr > 20)) return 'календарных дня';
    return 'календарных дней';
  }
}
