import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/study_remote.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/labeled_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.neutral900, width: 1.2),
      ),
      hintStyle: const TextStyle(color: AppColors.neutral500),
    );
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Введите email и пароль');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final err = await AuthService.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final snap = await fetchStudySnapshot();
    if (snap != null) await StudyStore.instance.applyServerPayload(snap);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(StudyMateRoutes.tabs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Вход',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Добро пожаловать!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),
              LabeledField(
                label: 'Email',
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDeco('student@example.com'),
                ),
              ),
              const SizedBox(height: 22),
              LabeledField(
                label: 'Пароль',
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: _fieldDeco('••••••••'),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Восстановление пароля появится в следующей версии.'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Забыли пароль?',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: _loading ? 'Вход…' : 'Войти',
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pushNamed(StudyMateRoutes.register),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 15, height: 1.35),
                      children: [
                        TextSpan(
                          text: 'Нет аккаунта? ',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                        TextSpan(
                          text: 'Зарегистрироваться',
                          style: TextStyle(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
