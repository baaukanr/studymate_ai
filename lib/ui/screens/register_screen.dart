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
      hintStyle: const TextStyle(color: AppColors.neutral500),
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.neutral900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Создайте аккаунт',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 28),
              LabeledField(
                label: 'Имя',
                child: TextField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: _fieldDeco('Иван'),
                ),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'Фамилия',
                child: TextField(
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                  decoration: _fieldDeco('Иванов'),
                ),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'Email',
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDeco('student@example.com'),
                ),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'Пароль',
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: _fieldDeco('Не менее 6 символов'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: _loading ? 'Регистрация…' : 'Создать аккаунт',
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
