import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _notify = 'studymate_notifications_enabled';

  static Future<bool> getNotificationsEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_notify) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notify, value);
  }
}
