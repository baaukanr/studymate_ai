import 'package:flutter/material.dart';

import '../data/plan_service.dart';
import '../data/study_models.dart';
import 'screens/create_exam_screen.dart';
import 'screens/create_plan_screen.dart';
import 'screens/exam_settings_screen.dart';
import 'screens/help_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/notifications_settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/topic_screen.dart';

class StudyMateRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const tabs = '/tabs';
  static const createExam = '/create-exam';
  static const createPlan = '/create-plan';
  static const loading = '/loading';
  static const plan = '/plan';
  static const topic = '/topic';
  static const examSettings = '/exam-settings';
  static const help = '/help';
  static const notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    switch (name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case tabs:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainTabs(),
        );
      case createExam:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateExamScreen(),
        );
      case createPlan:
        final ex = settings.arguments as ExamEntry?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreatePlanScreen(exam: ex),
        );
      case loading:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoadingScreen(),
        );
      case plan:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlanScreen(),
        );
      case topic:
        final args = settings.arguments;
        final day = args is PlanDay
            ? args
            : PlanDay.fromJson(const {
                'day': 1,
                'topic': 'Тема',
                'minutes': 45,
              });
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TopicScreen(day: day),
        );
      case examSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExamSettingsScreen(),
        );
      case help:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HelpScreen(),
        );
      case notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsSettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('Unknown route: $name')),
          ),
        );
    }
  }
}
