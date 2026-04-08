import 'package:flutter/material.dart';

import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Шаг 1: календарный экзамен (предмет + дата). Дни до экзамена ≠ дни плана.
class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({Key? key}) : super(key: key);

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _subject = TextEditingController();
  final _date = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _date.dispose();
    super.dispose();
  }

  void _next() {
    final subject = _subject.text.trim();
    final date = _date.text.trim();
    if (subject.isEmpty || date.isEmpty) {
      setState(() => _error = 'Укажите предмет и дату экзамена');
      return;
    }
    if (StudyStore.parseUserDate(date) == null) {
      setState(() => _error = 'Дата: используйте формат ДД.ММ.ГГГГ (например 12.04.2026)');
      return;
    }
    setState(() => _error = null);
    final exam = StudyStore.instance.addExam(subject: subject, examDate: date);
    Navigator.of(context).pushNamed(
      StudyMateRoutes.createPlan,
      arguments: exam,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Новый экзамен'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Сначала зафиксируйте экзамен: это календарная дата. План по дням (шаги подготовки) '
                'создаётся отдельно и не совпадает с «днями до экзамена».',
                style: TextStyle(color: AppColors.neutral500, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Text('Предмет', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: _subject,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Например: Математический анализ',
                ),
              ),
              const SizedBox(height: 14),
              const Text('Дата экзамена', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: _date,
                decoration: const InputDecoration(
                  hintText: 'ДД.ММ.ГГГГ',
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Далее: темы плана',
                icon: Icons.arrow_forward,
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
