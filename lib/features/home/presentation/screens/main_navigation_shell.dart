import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
import '../../../collections/presentation/bloc/collections_event.dart';
import '../../../collections/presentation/screens/collections_screen.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../history/presentation/bloc/history_event.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../monitor/presentation/bloc/monitor_bloc.dart';
import '../../../monitor/presentation/bloc/monitor_event.dart';
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

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      context.read<HistoryBloc>().add(const LoadHistoryEvent());
    } else if (index == 2) {
      context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
    } else if (index == 3) {
      context.read<MonitorBloc>().add(const LoadMonitorTargetsEvent());
    }
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
          onDestinationSelected: _onTabSelected,
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
