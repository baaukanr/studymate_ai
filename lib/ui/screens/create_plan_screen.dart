import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _subject = TextEditingController(text: 'Математический анализ');
  final _date = TextEditingController(text: '12.04.2026');
  final _topics = TextEditingController(
    text: 'Пределы\nПроизводные\nИнтегралы\nРяды',
  );

  @override
  void dispose() {
    _subject.dispose();
    _date.dispose();
    _topics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Создать план'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Заполните данные для персонального плана',
                style: TextStyle(color: AppColors.neutral500, fontSize: 16),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(
                  hintText: 'Например: Математический анализ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _date,
                decoration: const InputDecoration(
                  hintText: 'Дата экзамена',
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _topics,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Список тем/вопросов',
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Сгенерировать план',
                onPressed: () {
                  Navigator.of(context).pushNamed(StudyMateRoutes.loading);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

