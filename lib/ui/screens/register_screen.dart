import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/labeled_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
    final fn = _firstName.text.trim();
    final ln = _lastName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (fn.length < 2 || ln.length < 2) {
      setState(() => _error = 'Имя и фамилия — не короче 2 символов');
      return;
    }
    if (email.isEmpty || password.length < 6) {
      setState(() => _error = 'Укажите email и пароль (не короче 6 символов)');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final err = await AuthService.register(
      firstName: fn,
      lastName: ln,
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pushReplacementNamed(StudyMateRoutes.onboarding);
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
                top: -100,
                right: -70,
                child: Container(
                  width: 220,
                  height: 220,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                                        Icon(Icons.school, color: AppColors.primary, size: 36),
                                        SizedBox(height: 18),
                                        Text(
                                          'Создайте профиль за пару шагов',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.neutral900,
                                            height: 1.1,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Сохраните прогресс, получайте готовые планы и настраивайте расписание под себя.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(child: _buildForm()),
                              ],
                            )
                          : _buildForm(),
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

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: AppColors.neutral900,
              ),
              const SizedBox(width: 8),
              const Text(
                'Назад',
                style: TextStyle(color: AppColors.neutral900, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Регистрация',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Создайте профиль и начните готовиться с умным планом',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
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
                  label: 'Имя',
                  child: TextField(
                    controller: _firstName,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDeco('Иван'),
                  ),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Фамилия',
                  child: TextField(
                    controller: _lastName,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDeco('Иванов'),
                  ),
                ),
                const SizedBox(height: 18),
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
                    decoration: _fieldDeco('Не менее 6 символов'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 18),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 26),
          PrimaryButton(
            label: _loading ? 'Регистрация…' : 'Создать аккаунт',
            onPressed: _loading ? null : _submit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
