import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/request_builder/presentation/bloc/request_builder_bloc.dart';
import 'features/request_builder/presentation/screens/request_builder_screen.dart';

class PocketPingApp extends StatelessWidget {
  const PocketPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketPing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: BlocProvider<RequestBuilderBloc>(
        create: (_) => sl<RequestBuilderBloc>(),
        child: const RequestBuilderScreen(),
      ),
    );
  }
}
