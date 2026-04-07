import 'package:flutter/material.dart';

import '../ui/screens/splash_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/main_tabs.dart';
import '../ui/screens/create_plan_screen.dart';
import '../ui/screens/loading_screen.dart';
import '../ui/screens/plan_screen.dart';
import '../ui/screens/topic_screen.dart';

class StudyMateRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const tabs = '/tabs';
  static const createPlan = '/create-plan';
  static const loading = '/loading';
  static const plan = '/plan';
  static const topic = '/topic';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    switch (name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case tabs:
        return MaterialPageRoute(builder: (_) => const MainTabs());
      case createPlan:
        return MaterialPageRoute(builder: (_) => const CreatePlanScreen());
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case plan:
        return MaterialPageRoute(builder: (_) => const PlanScreen());
      case topic:
        final args = settings.arguments;
        final topicTitle = args is String ? args : 'Производные функций';
        return MaterialPageRoute(builder: (_) => TopicScreen(topicTitle: topicTitle));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Unknown route: $name')),
          ),
        );
    }
  }
}

