import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/environments_bloc.dart';
import '../bloc/environments_state.dart';
import 'environments_manager_dialog.dart';

class EnvironmentSelectorWidget extends StatelessWidget {
  const EnvironmentSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnvironmentsBloc, EnvironmentsState>(
      builder: (context, state) {
        String label = 'No Environment';
        bool hasActive = false;

        if (state is EnvironmentsLoadedState && state.selectedEnvironment != null) {
          label = state.selectedEnvironment!.name;
          hasActive = true;
        }

        return InkWell(
          onTap: () => EnvironmentsManagerDialog.show(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasActive ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: hasActive ? AppColors.statusSuccess : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: hasActive ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: hasActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
