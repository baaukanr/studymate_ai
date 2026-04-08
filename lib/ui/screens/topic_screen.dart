import 'package:flutter/material.dart';

import '../../data/plan_service.dart' show PlanDay, PlanService, PracticeTask;
import '../../data/plan_session_tracker.dart';
import '../../data/study_store.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class TopicScreen extends StatefulWidget {
  final PlanDay day;

  const TopicScreen({Key? key, required this.day}) : super(key: key);

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  static final _mathFlavor = RegExp(
    r'матем|алгебр|геометр|физик|хим|производн|интеграл|уравнен|логарифм',
    caseSensitive: false,
  );

  bool _isMathFlavor(PlanDay day) {
    final sub = (PlanService.currentPlan?.subject ?? '').toLowerCase();
    return _mathFlavor.hasMatch(sub) || _mathFlavor.hasMatch(day.topic.toLowerCase());
  }

  static String _formatStudyTime(int minutes) {
    if (minutes < 60) return '$minutes мин';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    String hoursRu(int n) {
      final r = n % 10;
      final rr = n % 100;
      if (r == 1 && rr != 11) return 'час';
      if (r >= 2 && r <= 4 && (rr < 10 || rr > 20)) return 'часа';
      return 'часов';
    }

    if (m == 0) return '$h ${hoursRu(h)}';
    return '$h ${hoursRu(h)} $m мин';
  }

  @override
  void initState() {
    super.initState();
    StudyStore.instance.addListener(_onStore);
    final planId = PlanService.currentPlanId;
    final plan = PlanService.currentPlan;
    if (planId != null && plan != null) {
      PlanSessionTracker.instance.startTopic(planId, widget.day.topic);
      StudyStore.instance.touchRecentMaterial(
        planId: planId,
        topic: widget.day.topic,
        subject: plan.subject,
        planDayIndex: widget.day.day,
      );
    }
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    StudyStore.instance.removeListener(_onStore);
    PlanSessionTracker.instance.stop();
    final planId = PlanService.currentPlanId;
    if (planId != null) {
      PlanSessionTracker.instance.startPlanList(planId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final subject = PlanService.currentPlan?.subject ?? 'Предмет';
    final planId = PlanService.currentPlanId;
    final saved = planId != null ? StudyStore.instance.getPlan(planId) : null;
    final topicSec = saved?.topicEngagementSeconds[day.topic] ?? 0;
    final topicProgress = day.minutes > 0
        ? (topicSec / (day.minutes * 60)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
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
              child: Text(
                'Шаг плана · день ${day.day} • $subject',
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              day.topic,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Text(
                  '${_formatStudyTime(day.minutes)} в плане на эту тему',
                  style: const TextStyle(color: AppColors.neutral500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    day.difficulty,
                    style: const TextStyle(color: AppColors.neutral500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Просмотр темы: ${(topicProgress * 100).round()}% от заложенного времени (обновляется по секундам)',
              style: const TextStyle(color: AppColors.neutral500, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: topicProgress,
                backgroundColor: AppColors.neutral200,
                valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
              ),
            ),
            const SizedBox(height: 18),
            _Section(
              title: day.whatIsTitle,
              body: day.whatIs,
            ),
            const SizedBox(height: 12),
            _RulesCard(rules: day.basicRules),
            const SizedBox(height: 12),
            _Section(
              title: 'Примеры применения',
              body: day.applicationExamples,
            ),
            if (day.practiceTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _isMathFlavor(day) ? 'Примеры задач' : 'Материалы для повторения',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...day.practiceTasks.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PracticeTaskCard(
                    index: e.key + 1,
                    task: e.value,
                    mathMode: _isMathFlavor(day),
                  ),
                );
              }),
            ],
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(color: AppColors.neutral500, height: 1.45, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _PracticeTaskCard extends StatefulWidget {
  final int index;
  final PracticeTask task;
  final bool mathMode;

  const _PracticeTaskCard({
    Key? key,
    required this.index,
    required this.task,
    required this.mathMode,
  }) : super(key: key);

  @override
  State<_PracticeTaskCard> createState() => _PracticeTaskCardState();
}

class _PracticeTaskCardState extends State<_PracticeTaskCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final label = widget.mathMode
        ? (_open ? 'Скрыть решение' : 'Показать решение')
        : (_open ? 'Скрыть пояснение' : 'Показать пояснение');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.mathMode ? 'Задача ${widget.index}' : 'Блок ${widget.index}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.neutral500),
          ),
          const SizedBox(height: 8),
          Text(
            t.prompt,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.4,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _open = !_open),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              primary: AppColors.neutral900,
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, decoration: TextDecoration.underline)),
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            Text(
              t.solution,
              style: const TextStyle(color: AppColors.neutral500, height: 1.45, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final List<String> rules;

  const _RulesCard({Key? key, required this.rules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Основные правила',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...List.generate(rules.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rules[i],
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        height: 1.45,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
