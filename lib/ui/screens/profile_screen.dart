import 'package:flutter/material.dart';

import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral200),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.neutral200,
                    child: Icon(Icons.person, color: AppColors.neutral900),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Мусаев Ернур',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ernur.musaev@almau.edu.kz',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Студент AlmaU',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: _StatCard(label: 'Экзаменов', value: '12')),
                SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Часов', value: '47')),
                SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Тем', value: '89')),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Статус планов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _ProgressRow(label: 'Математика', value: 0.60),
            const SizedBox(height: 10),
            const _ProgressRow(label: 'Физика', value: 0.40),
            const SizedBox(height: 10),
            const _ProgressRow(label: 'История', value: 0.85),
            const SizedBox(height: 10),
            const _ProgressRow(label: 'Программирование', value: 0.72),
            const SizedBox(height: 18),
            const Text(
              'Настройки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _SettingRow(label: 'Изменить данные экзамена'),
            const _SettingRow(label: 'Уведомления'),
            const _SettingRow(label: 'Конфиденциальность'),
            const _SettingRow(label: 'Помощь'),
            const _SettingRow(label: 'Выйти', danger: true),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;

  const _ProgressRow({Key? key, required this.label, required this.value})
      : super(key: key);

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
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text('${(value * 100).round()}%',
                  style: const TextStyle(color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: value,
              backgroundColor: AppColors.neutral200,
              valueColor: const AlwaysStoppedAnimation(AppColors.neutral900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final bool danger;

  const _SettingRow({Key? key, required this.label, this.danger = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.red600 : AppColors.neutral900;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.card,
      ),
      child: ListTile(
        onTap: () {},
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        trailing: Icon(Icons.chevron_right, color: danger ? color : AppColors.neutral500),
      ),
    );
  }
}

