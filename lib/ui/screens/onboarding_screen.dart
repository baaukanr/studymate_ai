import 'package:flutter/material.dart';

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

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(StudyMateRoutes.tabs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(StudyMateRoutes.tabs),
                  child: const Text(
                    'Пропустить',
                    style: TextStyle(color: AppColors.neutral900),
                  ),
                ),
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
                          height: 260,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neutral200),
                            boxShadow: AppShadows.card,
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome, size: 56),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == _page ? 20 : 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.neutral900
                          : AppColors.neutral200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: isLast ? 'Начать' : 'Далее',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String description;

  const _Slide({required this.title, required this.description});
}

