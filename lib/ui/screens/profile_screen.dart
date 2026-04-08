import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/study_models.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    StudyStore.instance.addListener(_onStore);
    _load();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    StudyStore.instance.removeListener(_onStore);
    super.dispose();
  }

  Future<void> _load() async {
    final cached = await AuthService.getCachedUser();
    if (mounted) setState(() => _user = cached);
    final fresh = await AuthService.refreshCurrentUser();
    if (mounted && fresh != null) setState(() => _user = fresh);
  }

  Future<void> _logout() async {
    await StudyStore.instance.clearLocal();
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(StudyMateRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final displayName = u != null && u.name.isNotEmpty ? u.name : 'Профиль';
    final email = u?.email ?? '—';
    final store = StudyStore.instance;
    final exams = store.totalExamsCount;
    final topics = store.totalTopicsCount;
    final hours = store.totalViewHours;
    final hoursRounded = hours < 0.05 ? 0 : (hours * 10).round() / 10;
    final plans = List<SavedPlanEntry>.from(store.plans)
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Профиль'),
      ),
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
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Экзаменов', value: '$exams')),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Часов', value: '$hoursRounded')),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Тем', value: '$topics')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Считается по сохранённым экзаменам и планам; часы — время с открытым планом и темами.',
              style: TextStyle(color: AppColors.neutral500.withOpacity(0.9), fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 20),
            const Text(
              'Статус планов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (plans.isEmpty)
              const Text(
                'Пока нет сохранённых планов. Создайте план на главной.',
                style: TextStyle(color: AppColors.neutral500, fontSize: 14),
              )
            else
              ...plans.map((p) {
                final target = p.totalPlanMinutes * 60;
                final prog = target > 0 ? (p.planEngagementSeconds / target).clamp(0.0, 1.0) : 0.0;
                final pct = (prog * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      StudyStore.instance.applyPlanToMemory(p);
                      Navigator.of(context).pushNamed(StudyMateRoutes.plan);
                    },
                    child: Container(
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
                            p.subject,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Экзамен: ${p.examDate} · план на ${StudyStore.formatPlanDurationRu(p.totalPlanMinutes)}',
                            style: const TextStyle(color: AppColors.neutral500, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    minHeight: 8,
                                    value: prog,
                                    backgroundColor: AppColors.neutral200,
                                    valueColor:
                                        const AlwaysStoppedAnimation(AppColors.neutral900),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 18),
            const Text(
              'Настройки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _SettingRow(
              label: 'Данные экзамена',
              onTap: () => Navigator.of(context).pushNamed(StudyMateRoutes.examSettings),
            ),
            _SettingRow(
              label: 'Уведомления',
              onTap: () => Navigator.of(context).pushNamed(StudyMateRoutes.notifications),
            ),
            _SettingRow(
              label: 'Конфиденциальность',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Раздел появится в обновлении.')),
                );
              },
            ),
            _SettingRow(
              label: 'Помощь',
              onTap: () => Navigator.of(context).pushNamed(StudyMateRoutes.help),
            ),
            _SettingRow(label: 'Выйти', danger: true, onTap: _logout),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({Key? key, required this.label, required this.value}) : super(key: key);

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

class _SettingRow extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingRow({
    Key? key,
    required this.label,
    this.danger = false,
    this.onTap,
  }) : super(key: key);

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
        onTap: onTap,
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        trailing: Icon(Icons.chevron_right, color: danger ? color : AppColors.neutral500),
      ),
    );
  }
}
