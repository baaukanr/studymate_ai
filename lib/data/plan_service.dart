import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_base.dart';

class PracticeTask {
  final String prompt;
  final String solution;

  const PracticeTask({
    required this.prompt,
    required this.solution,
  });

  factory PracticeTask.fromJson(Map<String, dynamic> json) {
    final p = (json['prompt'] as String? ?? json['question'] as String? ?? '').trim();
    final s = (json['solution'] as String? ?? json['answer'] as String? ?? '').trim();
    return PracticeTask(
      prompt: p.isNotEmpty ? p : 'Задание',
      solution: s.isNotEmpty ? s : 'Сверься с учебником и разбором.',
    );
  }

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'solution': solution,
      };
}

class PlanRequest {
  final String subject;
  final String examDate;
  final List<String> topics;

  const PlanRequest({
    required this.subject,
    required this.examDate,
    required this.topics,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'examDate': examDate,
        'topics': topics,
      };
}

class PlanDay {
  final int day;
  final String topic;
  final int minutes;
  final String difficulty;
  final String whatIsTitle;
  final String whatIs;
  final List<String> basicRules;
  final String applicationExamples;
  final String explanation;
  final List<PracticeTask> practiceTasks;

  PlanDay({
    required this.day,
    required this.topic,
    required this.minutes,
    required this.difficulty,
    required this.whatIsTitle,
    required this.whatIs,
    required this.basicRules,
    required this.applicationExamples,
    required this.explanation,
    List<PracticeTask>? practiceTasks,
  }) : practiceTasks = practiceTasks ?? <PracticeTask>[];

  factory PlanDay.fromJson(Map<String, dynamic> json) {
    final topic = (json['topic'] as String? ?? 'Тема').trim();
    final legacy = (json['explanation'] as String? ?? '').trim();
    final whatIs = (json['whatIs'] as String? ?? '').trim();
    final rulesRaw = json['basicRules'];
    final rules = <String>[];
    if (rulesRaw is List) {
      for (final r in rulesRaw) {
        if (r is String && r.trim().isNotEmpty) rules.add(r.trim());
      }
    }
    var title = (json['whatIsTitle'] as String? ?? '').trim();
    if (title.isEmpty) {
      title = topic.isNotEmpty ? 'Что такое «$topic»?' : 'Введение в тему';
    }
    final examples = (json['applicationExamples'] as String? ?? '').trim();
    final diff = (json['difficulty'] as String? ?? '').trim();
    final ptRaw = json['practiceTasks'];
    final tasks = <PracticeTask>[];
    if (ptRaw is List) {
      for (final e in ptRaw) {
        if (e is Map<String, dynamic>) tasks.add(PracticeTask.fromJson(e));
      }
    }
    if (tasks.length < 8) {
      tasks
        ..clear()
        ..addAll(_fallbackPracticeTasks(topic));
    }
    return PlanDay(
      day: (json['day'] as num?)?.toInt() ?? 1,
      topic: topic,
      minutes: (json['minutes'] as num?)?.toInt() ?? 45,
      difficulty: diff.isNotEmpty ? diff : 'Средний уровень',
      whatIsTitle: title,
      whatIs: whatIs.isNotEmpty ? whatIs : (legacy.isNotEmpty ? legacy : _defaultWhatIs(topic)),
      basicRules: rules.isNotEmpty ? rules : _defaultRules(topic),
      applicationExamples:
          examples.isNotEmpty ? examples : _defaultExamples(topic),
      explanation: legacy,
      practiceTasks: tasks,
    );
  }

  static List<PracticeTask> _fallbackPracticeTasks(String topic) {
    final mathy = RegExp(
      r'матем|алгебр|геометр|физик|хим|производн|интеграл|уравнен|логарифм',
      caseSensitive: false,
    ).hasMatch(topic);
    final out = <PracticeTask>[];
    for (var i = 1; i <= 10; i++) {
      if (mathy) {
        out.add(PracticeTask(
          prompt:
              'Задача $i по «$topic»: составь условие по аналогии с задачником и реши (запиши ход).',
          solution:
              'Опора: определения и формулы по теме. Пошагово упрости выражение, проверь ОДЗ и единицы. Сверь ответ с разбором в учебнике.',
        ));
      } else {
        out.add(PracticeTask(
          prompt: 'Блок $i: ключевой вопрос по «$topic» для экзамена.',
          solution:
              'Развёрнутый ответ: тезис, 2–3 аргумента, мини-пример. Свяжи с программой курса.',
        ));
      }
    }
    return out;
  }

  static String _defaultWhatIs(String topic) {
    return 'Тема «$topic» важна для экзамена. Начни с определения и интуиции: '
        'зачем это нужно в реальных задачах. Затем выучи ключевые правила и закрепи их примерами.';
  }

  static List<String> _defaultRules(String topic) {
    return [
      'Сформулируй своими словами, что такое «$topic».',
      'Запиши 3 ключевых факта или формулы по теме.',
      'Реши 2–3 типовых задания и сравни с разбором.',
    ];
  }

  static String _defaultExamples(String topic) {
    return 'Подумай, где «$topic» встречается в задачах курса и в быту '
        '(скорость роста, оптимизация, анализ графиков). Свяжи абстрактное определение с 1–2 конкретными ситуациями.';
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'topic': topic,
        'minutes': minutes,
        'difficulty': difficulty,
        'whatIsTitle': whatIsTitle,
        'whatIs': whatIs,
        'basicRules': basicRules,
        'applicationExamples': applicationExamples,
        'explanation': explanation,
        'practiceTasks': practiceTasks.map((t) => t.toJson()).toList(),
      };
}

class StudyPlan {
  final String subject;
  final String examDate;
  final List<PlanDay> days;

  const StudyPlan({
    required this.subject,
    required this.examDate,
    required this.days,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final days = <PlanDay>[];
    if (daysRaw is List) {
      for (final it in daysRaw) {
        if (it is Map<String, dynamic>) days.add(PlanDay.fromJson(it));
      }
    }
    return StudyPlan(
      subject: (json['subject'] as String? ?? 'Предмет').trim(),
      examDate: (json['examDate'] as String? ?? '').trim(),
      days: days,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'examDate': examDate,
        'days': days.map((d) => d.toJson()).toList(),
      };
}

class PlanService {
  static StudyPlan? currentPlan;
  /// Активный сохранённый план (для трекера времени и тем).
  static String? currentPlanId;
  static PlanRequest? pendingRequest;
  /// Экзамен, к которому привязывается создаваемый план.
  static String? pendingExamId;
  static bool lastPlanWasLocalFallback = false;

  static StudyPlan _localFallbackPlan(PlanRequest request) {
    final topics = request.topics;
    final subject = request.subject;
    final days = <PlanDay>[];
    for (var i = 0; i < topics.length; i++) {
      days.add(_localRichDay(
        dayIndex: i + 1,
        topic: topics[i],
        subject: subject,
      ));
    }
    return StudyPlan(
      subject: request.subject,
      examDate: request.examDate,
      days: days,
    );
  }

  static PlanDay _localRichDay({
    required int dayIndex,
    required String topic,
    required String subject,
  }) {
    final minutes = 90 + (dayIndex % 3) * 30;
    return PlanDay(
      day: dayIndex,
      topic: topic,
      minutes: minutes,
      difficulty: dayIndex % 2 == 0 ? 'Средний уровень' : 'Лёгкий уровень',
      whatIsTitle: 'Что такое «$topic»?',
      whatIs:
          '«$topic» — одна из опорных тем в дисциплине «$subject». Сначала пойми идею: '
          'зачем эта тема нужна и какую задачу она решает. Представь простую аналогию из жизни '
          '(скорость, рост, оптимизация времени) — так проще держать смысл в голове, а не только формулы.\n\n'
          'Дальше зафиксируй определение своими словами в 2–3 предложениях и проверь: сходится ли оно с учебником.',
      basicRules: [
        'Выдели 1 главную формулу или утверждение по теме «$topic» и выучи условия, когда оно работает.',
        'Разбей тему на 3 мини-шага: вводные понятия → типовой пример → типичная ошибка.',
        'Реши минимум 2 задачи разного типа и сравни ход решения с эталоном.',
      ],
      applicationExamples:
          'Применение темы «$topic» чаще всего встречается в задачах, где нужно связать абстрактную модель с данными: '
          'посчитать изменение величины, сравнить сценарии или выбрать оптимальный вариант. '
          'На экзамене обычно проверяют не зазубренность, а умение быстро выбрать метод.',
      explanation: '',
      practiceTasks: PlanDay._fallbackPracticeTasks(topic),
    );
  }

  static Future<String?> generatePlan(PlanRequest request) async {
    lastPlanWasLocalFallback = false;
    final apiBase = resolveApiBaseUrl();
    try {
      final err = await _requestPlan(request, apiBase);
      if (err != null) return err;
      return null;
    } catch (error) {
      if (kIsWeb && apiBase.contains('localhost')) {
        try {
          final altUrl = apiBase.replaceFirst('localhost', '127.0.0.1');
          final err = await _requestPlan(request, altUrl);
          if (err == null) return null;
          return err;
        } catch (_) {
          // Ignore retry failure and fall back locally.
        }
      }
      currentPlan = _localFallbackPlan(request);
      lastPlanWasLocalFallback = true;
      return null;
    }
  }

  static Future<String?> _requestPlan(PlanRequest request, String apiBase) async {
    final r = await http
        .post(
          Uri.parse('$apiBase/plan/generate'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 45));
    final body = _parseMap(r.body);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final err = body['error'];
      if (err is Map && err['message'] is String) {
        return err['message'] as String;
      }
      return 'Не удалось сгенерировать план (код ${r.statusCode})';
    }
    final planJson = body['plan'];
    if (planJson is! Map<String, dynamic>) {
      return 'Сервер вернул некорректный план';
    }
    currentPlan = StudyPlan.fromJson(planJson);
    if (currentPlan!.days.isEmpty) {
      return 'План пустой, попробуйте снова';
    }
    return null;
  }

  static Map<String, dynamic> _parseMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }
}
