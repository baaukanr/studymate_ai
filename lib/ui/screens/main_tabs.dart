import 'package:flutter/material.dart';

import '../theme.dart';
import 'dashboard_screen.dart';
import 'ai_chat_screen.dart';
import 'exams_screen.dart';
import 'profile_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({Key? key}) : super(key: key);

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    AiChatScreen(),
    ExamsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        if (!isWide) {
          return Scaffold(
            body: _screens[_index],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              elevation: 12,
              selectedItemColor: AppColors.neutral900,
              unselectedItemColor: AppColors.neutral500,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI‑чат'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Экзамены'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 100,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.auto_awesome, size: 28, color: AppColors.primary),
                    const SizedBox(height: 18),
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: (i) => setState(() => _index = i),
                        labelType: NavigationRailLabelType.all,
                        selectedIconTheme: const IconThemeData(color: AppColors.primary),
                        selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w700),
                        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
                        unselectedLabelTextStyle: const TextStyle(color: AppColors.neutral500),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            selectedIcon: Icon(Icons.home),
                            label: Text('Главная'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.chat_bubble),
                            selectedIcon: Icon(Icons.chat_bubble),
                            label: Text('AI‑чат'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.menu_book),
                            selectedIcon: Icon(Icons.menu_book),
                            label: Text('Экзамены'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Профиль'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        color: AppColors.surface,
                        child: _screens[_index],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

