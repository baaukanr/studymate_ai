class ExamEntry {
  final String id;
  final String subject;
  /// Как ввёл пользователь; календарные «дни до экзамена» считаются отдельно от «дней плана».
  final String examDate;
  final int createdAtMs;

  const ExamEntry({
    required this.id,
    required this.subject,
    required this.examDate,
    required this.createdAtMs,
  });

  factory ExamEntry.fromJson(Map<String, dynamic> json) {
    return ExamEntry(
      id: (json['id'] as String? ?? '').trim(),
      subject: (json['subject'] as String? ?? '').trim(),
      examDate: (json['examDate'] as String? ?? '').trim(),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'examDate': examDate,
        'createdAtMs': createdAtMs,
      };
}

/// Сохранённый план (ответ ИИ), привязанный к экзамену.
class SavedPlanEntry {
  final String id;
  final String examId;
  final String subject;
  final String examDate;
  final List<Map<String, dynamic>> daysJson;
  /// Сумма minutes по дням — «на сколько рассчитан план».
  final int totalPlanMinutes;
  /// Секунды с открытым планом/темами этого плана (для прогресса готовности).
  int planEngagementSeconds;
  /// Ключ — topic; время на экране темы (для «последних материалов»).
  final Map<String, int> topicEngagementSeconds;
  final int createdAtMs;

  SavedPlanEntry({
    required this.id,
    required this.examId,
    required this.subject,
    required this.examDate,
    required this.daysJson,
    required this.totalPlanMinutes,
    this.planEngagementSeconds = 0,
    Map<String, int>? topicEngagementSeconds,
    required this.createdAtMs,
  }) : topicEngagementSeconds = topicEngagementSeconds ?? {};

  factory SavedPlanEntry.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final days = <Map<String, dynamic>>[];
    if (daysRaw is List) {
      for (final e in daysRaw) {
        if (e is Map<String, dynamic>) days.add(e);
      }
    }
    final topicRaw = json['topicEngagementSeconds'];
    final topicMap = <String, int>{};
    if (topicRaw is Map) {
      topicRaw.forEach((k, v) {
        if (k is String && v is num) topicMap[k] = v.toInt();
      });
    }
    return SavedPlanEntry(
      id: (json['id'] as String? ?? '').trim(),
      examId: (json['examId'] as String? ?? '').trim(),
      subject: (json['subject'] as String? ?? '').trim(),
      examDate: (json['examDate'] as String? ?? '').trim(),
      daysJson: days,
      totalPlanMinutes: (json['totalPlanMinutes'] as num?)?.toInt() ?? 0,
      planEngagementSeconds: (json['planEngagementSeconds'] as num?)?.toInt() ?? 0,
      topicEngagementSeconds: topicMap,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examId': examId,
        'subject': subject,
        'examDate': examDate,
        'days': daysJson,
        'totalPlanMinutes': totalPlanMinutes,
        'planEngagementSeconds': planEngagementSeconds,
        'topicEngagementSeconds': topicEngagementSeconds,
        'createdAtMs': createdAtMs,
      };

  double readinessProgress(int liveExtraSeconds) {
    final target = totalPlanMinutes * 60;
    if (target <= 0) return 0;
    final v = (planEngagementSeconds + liveExtraSeconds) / target;
    if (v > 1) return 1;
    if (v < 0) return 0;
    return v;
  }

  int topicProgressPercent(String topic, int allocatedMinutes, int liveExtraSeconds) {
    final target = allocatedMinutes * 60;
    if (target <= 0) return 0;
    final spent = (topicEngagementSeconds[topic] ?? 0) + liveExtraSeconds;
    final p = (spent / target * 100).round();
    if (p > 100) return 100;
    if (p < 0) return 0;
    return p;
  }
}

class RecentMaterialEntry {
  final String planId;
  final String topic;
  final String subject;
  final int planDayIndex;
  final int lastAccessMs;

  const RecentMaterialEntry({
    required this.planId,
    required this.topic,
    required this.subject,
    required this.planDayIndex,
    required this.lastAccessMs,
  });

  factory RecentMaterialEntry.fromJson(Map<String, dynamic> json) {
    return RecentMaterialEntry(
      planId: (json['planId'] as String? ?? '').trim(),
      topic: (json['topic'] as String? ?? '').trim(),
      subject: (json['subject'] as String? ?? '').trim(),
      planDayIndex: (json['planDayIndex'] as num?)?.toInt() ?? 1,
      lastAccessMs: (json['lastAccessMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'topic': topic,
        'subject': subject,
        'planDayIndex': planDayIndex,
        'lastAccessMs': lastAccessMs,
      };
}
