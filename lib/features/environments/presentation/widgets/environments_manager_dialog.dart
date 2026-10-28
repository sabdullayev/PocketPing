import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/environment_entity.dart';
import '../../domain/entities/environment_variable.dart';
import '../bloc/environments_bloc.dart';
import '../bloc/environments_event.dart';
import '../bloc/environments_state.dart';

class EnvironmentsManagerDialog extends StatefulWidget {
  const EnvironmentsManagerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EnvironmentsManagerDialog(),
    );
  }

  @override
  State<EnvironmentsManagerDialog> createState() => _EnvironmentsManagerDialogState();
}

class _EnvironmentsManagerDialogState extends State<EnvironmentsManagerDialog> {
  String? _selectedEnvId;

  void _showAddEnvironmentDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        backgroundColor: AppColors.card,
        title: const Text('New Environment'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Staging, Localhost'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newEnv = EnvironmentEntity(name: name, variables: [
                  EnvironmentVariable(key: 'base_url', value: 'https://api.example.com'),
                ]);
                context.read<EnvironmentsBloc>().add(SaveEnvironmentEvent(newEnv));
                setState(() => _selectedEnvId = newEnv.id);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<EnvironmentsBloc, EnvironmentsState>(
        builder: (context, state) {
          if (state is EnvironmentsLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is EnvironmentsLoadedState) {
            if (state.environments.isEmpty) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: _showAddEnvironmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Environment'),
                ),
              );
            }

            final currentEnv = state.environments.firstWhere(
              (e) => e.id == (_selectedEnvId ?? state.selectedEnvironment?.id),
              orElse: () => state.environments.first,
            );

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Environments & Variables',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Environment Tabs / Selector Row
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...state.environments.map((env) {
                                final isTabActive = env.id == currentEnv.id;
                                final isSelectedGlobal = env.isSelected;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelectedGlobal) ...[
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppColors.statusSuccess,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(env.name),
                                      ],
                                    ),
                                    selected: isTabActive,
                                    selectedColor: AppColors.card,
                                    backgroundColor: AppColors.surface,
                                    labelStyle: TextStyle(
                                      color: isTabActive ? AppColors.primary : AppColors.textSecondary,
                                      fontWeight: isTabActive ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    onSelected: (_) => setState(() => _selectedEnvId = env.id),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        tooltip: 'Add Environment',
                        onPressed: _showAddEnvironmentDialog,
                      ),
                    ],
                  ),
                ),

                // Environment Action bar (Set Active, Delete)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentEnv.isSelected ? AppColors.statusSuccess : AppColors.card,
                          foregroundColor: currentEnv.isSelected ? Colors.black : AppColors.textPrimary,
                        ),
                        onPressed: () {
                          context.read<EnvironmentsBloc>().add(
                                SelectEnvironmentEvent(currentEnv.isSelected ? null : currentEnv.id),
                              );
                        },
                        icon: Icon(
                          currentEnv.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        label: Text(currentEnv.isSelected ? 'Active Environment' : 'Set as Active'),
                      ),
                      const Spacer(),
                      if (state.environments.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.methodDelete, size: 20),
                          tooltip: 'Delete Environment',
                          onPressed: () {
                            context.read<EnvironmentsBloc>().add(DeleteEnvironmentEvent(currentEnv.id));
                            setState(() => _selectedEnvId = null);
                          },
                        ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.border, height: 1),

                // Variables List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Variables (Use as {{variable_name}} in request)',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final updatedVars = List<EnvironmentVariable>.from(currentEnv.variables)
                            ..add(EnvironmentVariable(key: '', value: ''));
                          context.read<EnvironmentsBloc>().add(
                                SaveEnvironmentEvent(currentEnv.copyWith(variables: updatedVars)),
                              );
                        },
                        icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                        label: const Text('Add Variable', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                // Variables List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: currentEnv.variables.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final variable = currentEnv.variables[idx];
                      return _VariableRow(
                        key: ValueKey(variable.id),
                        variable: variable,
                        onUpdate: (k, v) {
                          final updatedVars = currentEnv.variables.map((x) {
                            if (x.id == variable.id) {
                              return x.copyWith(key: k, value: v);
                            }
                            return x;
                          }).toList();
                          context.read<EnvironmentsBloc>().add(
                                SaveEnvironmentEvent(currentEnv.copyWith(variables: updatedVars)),
                              );
                        },
                        onToggle: () {
                          final updatedVars = currentEnv.variables.map((x) {
                            if (x.id == variable.id) {
                              return x.copyWith(isEnabled: !x.isEnabled);
                            }
                            return x;
                          }).toList();
                          context.read<EnvironmentsBloc>().add(
                                SaveEnvironmentEvent(currentEnv.copyWith(variables: updatedVars)),
                              );
                        },
                        onDelete: () {
                          final updatedVars = currentEnv.variables.where((x) => x.id != variable.id).toList();
                          context.read<EnvironmentsBloc>().add(
                                SaveEnvironmentEvent(currentEnv.copyWith(variables: updatedVars)),
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ),
    );
  }
}

class _VariableRow extends StatefulWidget {
  final EnvironmentVariable variable;
  final Function(String key, String val) onUpdate;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _VariableRow({
    super.key,
    required this.variable,
    required this.onUpdate,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_VariableRow> createState() => _VariableRowState();
}

class _VariableRowState extends State<_VariableRow> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.variable.key);
    _valueController = TextEditingController(text: widget.variable.value);
  }

  @override
  void didUpdateWidget(covariant _VariableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variable.key != widget.variable.key && _keyController.text != widget.variable.key) {
      _keyController.text = widget.variable.key;
    }
    if (oldWidget.variable.value != widget.variable.value && _valueController.text != widget.variable.value) {
      _valueController.text = widget.variable.value;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.variable.isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.variable.isEnabled,
            activeColor: AppColors.primary,
            onChanged: (_) => widget.onToggle(),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _keyController,
              onChanged: (k) => widget.onUpdate(k, _valueController.text),
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: widget.variable.isEnabled ? AppColors.accent : AppColors.textMuted,
              ),
              decoration: const InputDecoration(
                hintText: 'VARIABLE_NAME',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: AppColors.border),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _valueController,
              onChanged: (v) => widget.onUpdate(_keyController.text, v),
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: widget.variable.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              decoration: const InputDecoration(
                hintText: 'Value',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
