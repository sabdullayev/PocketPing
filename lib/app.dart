import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/collections/presentation/bloc/collections_bloc.dart';
import 'features/environments/presentation/bloc/environments_bloc.dart';
import 'features/environments/presentation/bloc/environments_event.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/history/presentation/bloc/history_event.dart';
import 'features/home/presentation/screens/main_navigation_shell.dart';
import 'features/monitor/presentation/bloc/monitor_bloc.dart';
import 'features/request_builder/presentation/bloc/request_builder_bloc.dart';

class PocketPingApp extends StatelessWidget {
  const PocketPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EnvironmentsBloc>(
          create: (_) => sl<EnvironmentsBloc>()..add(const LoadEnvironmentsEvent()),
        ),
        BlocProvider<RequestBuilderBloc>(
          create: (_) => sl<RequestBuilderBloc>(),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => sl<HistoryBloc>()..add(const LoadHistoryEvent()),
        ),
        BlocProvider<CollectionsBloc>(
          create: (_) => sl<CollectionsBloc>(),
        ),
        BlocProvider<MonitorBloc>(
          create: (_) => sl<MonitorBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PocketPing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationShell(),
      ),
    );
  }
}
