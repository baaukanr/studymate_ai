import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/study_remote.dart';
import '../../data/study_store.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _Slide(
      title: 'ИИ составляет план подготовки',
      description:
          'Введите предмет и темы — искусственный интеллект создаст персональный план за секунды',
    ),
    _Slide(
      title: 'Краткие объяснения сложных тем',
      description:
          'Получайте простые и понятные объяснения любой темы с помощью AI‑ассистента',
    ),
    _Slide(
      title: 'Экономия времени и снижение стресса',
      description:
          'Больше никакой паники перед экзаменом. Учись эффективно и спокойно',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncStudyIfAuthorized() async {
    if (!await AuthService.isAuthorized()) return;
    final snap = await fetchStudySnapshot();
    if (snap != null) await StudyStore.instance.applyServerPayload(snap);
  }

  Future<void> _next() async {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      await _syncStudyIfAuthorized();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(StudyMateRoutes.tabs);
    }
  }

  Future<void> _skipToTabs() async {
    await _syncStudyIfAuthorized();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(StudyMateRoutes.tabs);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 1),
                          TextButton(
                            onPressed: _skipToTabs,
                            child: const Text('Пропустить'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _slides.length,
                          onPageChanged: (p) => setState(() => _page = p),
                          itemBuilder: (context, i) {
                            final s = _slides[i];
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                Container(
                                  height: 280,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.card,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: AppColors.borderSubtle),
                                    boxShadow: AppShadows.card,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.hero,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.auto_awesome, size: 50, color: AppColors.white),
                                      ),
                                      const SizedBox(height: 22),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          s.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.neutral900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 28),
                                        child: Text(
                                          s.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 10,
                            width: i == _page ? 26 : 10,
                            decoration: BoxDecoration(
                              color: i == _page ? AppColors.primary : AppColors.neutral200,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: isLast ? 'Начать' : 'Далее',
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Slide {
  final String title;
  final String description;

  const _Slide({required this.title, required this.description});
}

