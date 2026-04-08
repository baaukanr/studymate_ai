import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_service.dart';
import 'study_models.dart';
import 'study_remote.dart';

/// Локальное хранилище экзаменов, планов, прогресса; синхронизация с сервером по аккаунту.
class StudyStore extends ChangeNotifier {
  StudyStore._();
  static final StudyStore instance = StudyStore._();

  static const _prefsKey = 'study_mate_data_v2';

  final List<ExamEntry> exams = [];
  final List<SavedPlanEntry> plans = [];
  final List<RecentMaterialEntry> recentMaterials = [];

  Timer? _persistDebounce;
  bool _muteRemotePush = false;

  static DateTime? parseUserDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final parts = s.split(RegExp(r'[./-]'));
    if (parts.length != 3) return null;
    final a = int.tryParse(parts[0].trim());
    final b = int.tryParse(parts[1].trim());
    var c = int.tryParse(parts[2].trim());
    if (a == null || b == null || c == null) return null;
    if (c < 100) c += 2000;
    try {
      if (a > 31) {
        return DateTime(a, b, c);
      }
      return DateTime(c, b, a);
    } catch (_) {
      return null;
    }
  }

  static int? calendarDaysUntilExam(String examDateStr) {
    final d = parseUserDate(examDateStr);
    if (d == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ex = DateTime(d.year, d.month, d.day);
    return ex.difference(today).inDays;
  }

  static String formatPlanDurationRu(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes мин';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (m == 0) return '$h ч';
    return '$h ч $m мин';
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey);
    exams.clear();
    plans.clear();
    recentMaterials.clear();
    if (raw == null || raw.isEmpty) {
      notifyListeners();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ex = map['exams'];
      if (ex is List) {
        for (final e in ex) {
          if (e is Map<String, dynamic>) exams.add(ExamEntry.fromJson(e));
        }
      }
      final pl = map['plans'];
      if (pl is List) {
        for (final e in pl) {
          if (e is Map<String, dynamic>) plans.add(SavedPlanEntry.fromJson(e));
        }
      }
      final r = map['recentMaterials'];
      if (r is List) {
        for (final e in r) {
          if (e is Map<String, dynamic>) {
            recentMaterials.add(RecentMaterialEntry.fromJson(e));
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  void _schedulePersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 400), _persistNow);
  }

  Future<void> _persistNow() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _prefsKey,
      jsonEncode(toSyncPayload()),
    );
    if (!_muteRemotePush) {
      pushStudySnapshot(toSyncPayload());
    }
  }

  Map<String, dynamic> toSyncPayload() => {
        'exams': exams.map((e) => e.toJson()).toList(),
        'plans': plans.map((e) => e.toJson()).toList(),
        'recentMaterials': recentMaterials.map((e) => e.toJson()).toList(),
      };

  static List<ExamEntry> _examListFromJson(dynamic raw) {
    if (raw is! List) return [];
    final out = <ExamEntry>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) out.add(ExamEntry.fromJson(e));
    }
    return out;
  }

  static List<SavedPlanEntry> _planListFromJson(dynamic raw) {
    if (raw is! List) return [];
    final out = <SavedPlanEntry>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) out.add(SavedPlanEntry.fromJson(e));
    }
    return out;
  }

  static List<RecentMaterialEntry> _recentListFromJson(dynamic raw) {
    if (raw is! List) return [];
    final out = <RecentMaterialEntry>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) out.add(RecentMaterialEntry.fromJson(e));
    }
    return out;
  }

  /// Объединяет ответ сервера с уже загруженными локальными данными (SharedPreferences),
  /// чтобы пустой или устаревший снимок на сервере не стирал экзамены после F5 / перезапуска.
  void _mergePayloadFromServer(Map<String, dynamic> json) {
    final serverExams = _examListFromJson(json['exams']);
    final serverPlans = _planListFromJson(json['plans']);
    final serverRecent = _recentListFromJson(json['recentMaterials']);

    final examById = <String, ExamEntry>{for (final e in exams) e.id: e};
    for (final e in serverExams) {
      examById[e.id] = e;
    }
    exams
      ..clear()
      ..addAll(examById.values);

    final planById = <String, SavedPlanEntry>{for (final p in plans) p.id: p};
    for (final p in serverPlans) {
      planById[p.id] = p;
    }
    plans
      ..clear()
      ..addAll(planById.values);

    final recentByKey = <String, RecentMaterialEntry>{};
    for (final r in recentMaterials) {
      recentByKey['${r.planId}|${r.topic}'] = r;
    }
    for (final r in serverRecent) {
      final k = '${r.planId}|${r.topic}';
      final prev = recentByKey[k];
      if (prev == null || r.lastAccessMs > prev.lastAccessMs) {
        recentByKey[k] = r;
      }
    }
    recentMaterials
      ..clear()
      ..addAll(recentByKey.values);
    recentMaterials.sort((a, b) => b.lastAccessMs.compareTo(a.lastAccessMs));
    while (recentMaterials.length > 12) {
      recentMaterials.removeLast();
    }
  }

  Future<void> applyServerPayload(Map<String, dynamic> json) async {
    _muteRemotePush = true;
    _mergePayloadFromServer(json);
    notifyListeners();
    await _persistNow();
    _muteRemotePush = false;
    await pushStudySnapshot(toSyncPayload());
  }

  Future<void> clearLocal() async {
    _muteRemotePush = true;
    exams.clear();
    plans.clear();
    recentMaterials.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove(_prefsKey);
    PlanService.currentPlan = null;
    PlanService.currentPlanId = null;
    _muteRemotePush = false;
    notifyListeners();
  }

  void updateExam(String id, {String? subject, String? examDate}) {
    final idx = exams.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final e = exams[idx];
    exams[idx] = ExamEntry(
      id: e.id,
      subject: subject != null ? subject.trim() : e.subject,
      examDate: examDate != null ? examDate.trim() : e.examDate,
      createdAtMs: e.createdAtMs,
    );
    for (var i = 0; i < plans.length; i++) {
      if (plans[i].examId != id) continue;
      final p = plans[i];
      plans[i] = SavedPlanEntry(
        id: p.id,
        examId: p.examId,
        subject: subject != null ? subject.trim() : p.subject,
        examDate: examDate != null ? examDate.trim() : p.examDate,
        daysJson: List<Map<String, dynamic>>.from(
          p.daysJson.map((m) => Map<String, dynamic>.from(m)),
        ),
        totalPlanMinutes: p.totalPlanMinutes,
        planEngagementSeconds: p.planEngagementSeconds,
        topicEngagementSeconds: Map<String, int>.from(p.topicEngagementSeconds),
        createdAtMs: p.createdAtMs,
      );
    }
    _schedulePersist();
    notifyListeners();
  }

  void removeExamAndPlans(String examId) {
    final doomedIds = plans.where((p) => p.examId == examId).map((p) => p.id).toSet();
    exams.removeWhere((e) => e.id == examId);
    plans.removeWhere((p) => p.examId == examId);
    recentMaterials.removeWhere((r) => doomedIds.contains(r.planId));
    _schedulePersist();
    notifyListeners();
  }

  String newId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  }

  ExamEntry addExam({required String subject, required String examDate}) {
    final e = ExamEntry(
      id: newId(),
      subject: subject.trim(),
      examDate: examDate.trim(),
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    exams.add(e);
    _schedulePersist();
    notifyListeners();
    return e;
  }

  ExamEntry? getExam(String id) {
    for (final e in exams) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Сохранить сгенерированный план и выставить активный в памяти.
  SavedPlanEntry saveGeneratedPlan({
    required String examId,
    required StudyPlan plan,
  }) {
    final daysJson = plan.days.map((d) => d.toJson()).toList();
    final total = plan.days.fold<int>(0, (a, d) => a + d.minutes);
    final entry = SavedPlanEntry(
      id: newId(),
      examId: examId,
      subject: plan.subject,
      examDate: plan.examDate,
      daysJson: daysJson,
      totalPlanMinutes: total,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    plans.add(entry);
    PlanService.currentPlanId = entry.id;
    PlanService.currentPlan = plan;
    _schedulePersist();
    notifyListeners();
    return entry;
  }

  SavedPlanEntry? getPlan(String id) {
    for (final p in plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  void applyPlanToMemory(SavedPlanEntry entry) {
    final days = entry.daysJson.map((m) => PlanDay.fromJson(m)).toList();
    PlanService.lastPlanWasLocalFallback = false;
    PlanService.currentPlanId = entry.id;
    PlanService.currentPlan = StudyPlan(
      subject: entry.subject,
      examDate: entry.examDate,
      days: days,
    );
  }

  void addEngagementTick(String planId, {String? topic}) {
    final p = getPlan(planId);
    if (p == null) return;
    p.planEngagementSeconds += 1;
    if (topic != null && topic.isNotEmpty) {
      p.topicEngagementSeconds[topic] = (p.topicEngagementSeconds[topic] ?? 0) + 1;
    }
    notifyListeners();
    _schedulePersist();
  }

  void touchRecentMaterial({
    required String planId,
    required String topic,
    required String subject,
    required int planDayIndex,
  }) {
    recentMaterials.removeWhere(
      (r) => r.planId == planId && r.topic == topic,
    );
    recentMaterials.insert(
      0,
      RecentMaterialEntry(
        planId: planId,
        topic: topic,
        subject: subject,
        planDayIndex: planDayIndex,
        lastAccessMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    while (recentMaterials.length > 12) {
      recentMaterials.removeLast();
    }
    notifyListeners();
    _schedulePersist();
  }

  /// Ближайший предстоящий экзамен; если таких нет — ближайший по календарю.
  ExamEntry? nearestExam() {
    if (exams.isEmpty) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    ExamEntry? bestFuture;
    int? bestFutureD;
    ExamEntry? bestAny;
    int? bestAnyAbs;
    for (final e in exams) {
      final d = parseUserDate(e.examDate);
      if (d == null) continue;
      final ex = DateTime(d.year, d.month, d.day);
      final dist = ex.difference(today).inDays;
      final abs = dist < 0 ? -dist : dist;
      if (bestAny == null || abs < (bestAnyAbs ?? 99999)) {
        bestAny = e;
        bestAnyAbs = abs;
      }
      if (dist >= 0 && (bestFutureD == null || dist < bestFutureD)) {
        bestFuture = e;
        bestFutureD = dist;
      }
    }
    return bestFuture ?? bestAny;
  }

  /// Последний план для экзамена (для карточки на главной).
  SavedPlanEntry? latestPlanForExam(String examId) {
    SavedPlanEntry? last;
    for (final p in plans) {
      if (p.examId != examId) continue;
      if (last == null || p.createdAtMs > last.createdAtMs) last = p;
    }
    return last;
  }

  int get totalExamsCount => exams.length;

  int get totalTopicsCount {
    var n = 0;
    for (final p in plans) {
      n += p.daysJson.length;
    }
    return n;
  }

  double get totalViewHours {
    var sec = 0;
    for (final p in plans) {
      sec += p.planEngagementSeconds;
    }
    return sec / 3600.0;
  }
}
