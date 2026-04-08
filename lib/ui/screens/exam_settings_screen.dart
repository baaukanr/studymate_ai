import 'package:flutter/material.dart';

import '../../data/study_models.dart';
import '../../data/study_store.dart';
import '../theme.dart';

/// Редактирование и удаление экзаменов (календарные даты), без изменения шагов плана вручную.
class ExamSettingsScreen extends StatefulWidget {
  const ExamSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ExamSettingsScreen> createState() => _ExamSettingsScreenState();
}

class _ExamSettingsScreenState extends State<ExamSettingsScreen> {
  @override
  void initState() {
    super.initState();
    StudyStore.instance.addListener(_r);
  }

  void _r() => setState(() {});

  @override
  void dispose() {
    StudyStore.instance.removeListener(_r);
    super.dispose();
  }

  Future<void> _edit(ExamEntry e) async {
    final subj = TextEditingController(text: e.subject);
    final date = TextEditingController(text: e.examDate);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Данные экзамена'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subj,
                  decoration: const InputDecoration(labelText: 'Предмет'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: date,
                  decoration: const InputDecoration(
                    labelText: 'Дата (ДД.ММ.ГГГГ)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    if (StudyStore.parseUserDate(date.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректная дата')),
      );
      return;
    }
    StudyStore.instance.updateExam(
      e.id,
      subject: subj.text.trim(),
      examDate: date.text.trim(),
    );
  }

  Future<void> _delete(ExamEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить экзамен?'),
        content: Text(
          'Будут удалены все планы, привязанные к «${e.subject}». Это действие синхронизируется с аккаунтом.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: AppColors.red600)),
          ),
        ],
      ),
    );
    if (ok == true) {
      StudyStore.instance.removeExamAndPlans(e.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = List<ExamEntry>.from(StudyStore.instance.exams)
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Экзамены'),
      ),
      body: SafeArea(
        child: list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Нет экзаменов. Добавьте на главной.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral500),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final e = list[i];
                  final d = StudyStore.calendarDaysUntilExam(e.examDate);
                  return Container(
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
                        Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Дата: ${e.examDate}', style: const TextStyle(color: AppColors.neutral500)),
                        if (d != null)
                          Text(
                            d >= 0 ? 'До экзамена: $d календ. дн.' : 'Дата прошла',
                            style: const TextStyle(color: AppColors.neutral500, fontSize: 13),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _edit(e),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Изменить'),
                            ),
                            TextButton.icon(
                              onPressed: () => _delete(e),
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red600),
                              label: const Text('Удалить', style: TextStyle(color: AppColors.red600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
