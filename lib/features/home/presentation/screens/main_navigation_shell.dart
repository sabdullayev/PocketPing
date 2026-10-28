import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../collections/presentation/screens/collections_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../monitor/presentation/screens/monitor_screen.dart';
import '../../../request_builder/presentation/screens/request_builder_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _navigateToBuilder() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const RequestBuilderScreen(),
          HistoryScreen(onNavigateToBuilder: _navigateToBuilder),
          CollectionsScreen(onNavigateToBuilder: _navigateToBuilder),
          const MonitorScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.bolt, color: AppColors.primary),
              label: 'Ping',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.history, color: AppColors.primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.folder, color: AppColors.primary),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.monitor_heart, color: AppColors.methodDelete),
              label: 'Monitor',
            ),
          ],
        ),
      ),
    );
  }
}
