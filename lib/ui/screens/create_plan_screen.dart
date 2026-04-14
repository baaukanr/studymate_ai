import 'package:flutter/material.dart';

import '../../data/plan_service.dart';
import '../../data/study_models.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Шаг 2: темы для ИИ. Предмет и дата берутся из экзамена.
class CreatePlanScreen extends StatefulWidget {
  final ExamEntry? exam;

  const CreatePlanScreen({Key? key, this.exam}) : super(key: key);

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _topics = TextEditingController();
  String? _error;

  ExamEntry? get _exam => widget.exam;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_exam == null && mounted) {
        Navigator.of(context).pushReplacementNamed(StudyMateRoutes.createExam);
      }
    });
  }

  @override
  void dispose() {
    _topics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exam;
    if (ex == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Темы плана'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ex.subject,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Экзамен: ${ex.examDate}',
                style: const TextStyle(color: AppColors.neutral500, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ниже — шаги плана (день 1, день 2…). Это не то же самое, что календарные дни до экзамена.',
                style: TextStyle(color: AppColors.neutral500, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 16),
              const Text(
                'Список тем или вопросов',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _topics,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Каждая тема с новой строки',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Создать план',
                onPressed: () {
                  final topics = _topics.text
                      .split(RegExp(r'[\n,;]'))
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  if (topics.isEmpty) {
                    setState(() => _error = 'Добавьте хотя бы одну тему');
                    return;
                  }
                  setState(() => _error = null);
                  PlanService.pendingExamId = ex.id;
                  final request = PlanRequest(
                    subject: ex.subject,
                    examDate: ex.examDate,
                    topics: topics,
                  );
                  PlanService.pendingRequest = request;
                  Navigator.of(context).pushNamed(
                    StudyMateRoutes.loading,
                    arguments: request,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
