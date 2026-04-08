import 'package:flutter/material.dart';

import '../../data/user_prefs.dart';
import '../theme.dart';

/// Заглушка: переключатель двигается, push-пока не подключён.
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _on = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await UserPrefs.getNotificationsEnabled();
    if (mounted) setState(() {
      _on = v;
      _loading = false;
    });
  }

  Future<void> _set(bool v) async {
    setState(() => _on = v);
    await UserPrefs.setNotificationsEnabled(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Уведомления'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppShadows.cardSoft,
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Получать уведомления',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      subtitle: const Text(
                        'Пока только настройка интерфейса. Реальные push появятся в обновлении.',
                        style: TextStyle(color: AppColors.neutral500, fontSize: 13),
                      ),
                      value: _on,
                      activeColor: AppColors.neutral900,
                      onChanged: _set,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
