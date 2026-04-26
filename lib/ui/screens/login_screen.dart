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
      hintStyle: const TextStyle(color: AppColors.textSecondary),
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
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Stack(
            children: [
              Container(decoration: const BoxDecoration(gradient: AppGradients.authBackground)),
              Positioned(
                top: -120,
                left: -80,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                right: -80,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 1100 : double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: AppShadows.card,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 36),
                                        SizedBox(height: 18),
                                        Text(
                                          'Добро пожаловать в StudyMate AI',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.neutral900,
                                            height: 1.1,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Персональные планы, удобные уроки и помощь в подготовке к экзаменам — прямо в браузере.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 28),
                                        Text(
                                          'Начните с удобного и современного интерфейса, где все важные функции под рукой.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(child: _buildForm(context)),
                              ],
                            )
                          : _buildForm(context),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.cardSoft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.white, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'StudyMate AI',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'Вход',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Начните учиться с удобным AI-помощником',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledField(
                  label: 'Email',
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDeco('student@example.com'),
                  ),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Пароль',
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: _fieldDeco('••••••••'),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Восстановление пароля появится в следующей версии.'),
                        ),
                      );
                    },
                    child: const Text('Забыли пароль?'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
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
          const SizedBox(height: 22),
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
                      style: TextStyle(color: AppColors.textSecondary),
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
    );
  }
}
