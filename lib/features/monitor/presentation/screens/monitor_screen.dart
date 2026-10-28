import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/monitor_target_entity.dart';
import '../bloc/monitor_bloc.dart';
import '../bloc/monitor_event.dart';
import '../bloc/monitor_state.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MonitorBloc>().add(const LoadMonitorTargetsEvent());
  }

  void _showAddTargetDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController(text: 'https://');
    int selectedInterval = 15;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          scrollable: true,
          backgroundColor: AppColors.card,
          title: const Row(
            children: [
              Icon(Icons.add_alert_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text('Add Health Check Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Target Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'e.g. Auth Service, Production API'),
              ),
              const SizedBox(height: 12),
              const Text('URL Endpoint', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(hintText: 'https://api.mysite.com/health'),
              ),
              const SizedBox(height: 12),
              const Text('Check Interval', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedInterval,
                    isExpanded: true,
                    dropdownColor: AppColors.card,
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('Every 15 minutes (Standard)')),
                      DropdownMenuItem(value: 30, child: Text('Every 30 minutes')),
                      DropdownMenuItem(value: 60, child: Text('Every 60 minutes')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedInterval = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final url = urlController.text.trim();
                if (url.isNotEmpty && url != 'https://') {
                  context.read<MonitorBloc>().add(
                        AddMonitorTargetEvent(
                          name: name.isEmpty ? url : name,
                          url: url,
                          intervalMinutes: selectedInterval,
                        ),
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Target'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.methodDelete, size: 22),
            SizedBox(width: 8),
            Text('Server Health Monitor', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Ping All Now',
            onPressed: () => context.read<MonitorBloc>().add(const PingAllTargetsEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Add Target',
            onPressed: _showAddTargetDialog,
          ),
        ],
      ),
      body: BlocBuilder<MonitorBloc, MonitorState>(
        builder: (context, state) {
          if (state is MonitorLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is MonitorLoadedState) {
            if (state.targets.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 56,
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No health check targets',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add critical API endpoints to monitor them in the background.\nYou will receive a notification if a server goes down (502 or timeout).',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddTargetDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Server Target'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.targets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final target = state.targets[index];
                final isPinging = state.pingingTargetId == target.id;

                return _MonitorTargetCard(
                  target: target,
                  isPinging: isPinging,
                  onPing: () => context.read<MonitorBloc>().add(PingTargetEvent(target)),
                  onToggle: () => context.read<MonitorBloc>().add(ToggleMonitorTargetEvent(target.id)),
                  onDelete: () => context.read<MonitorBloc>().add(DeleteMonitorTargetEvent(target.id)),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddTargetDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MonitorTargetCard extends StatelessWidget {
  final MonitorTargetEntity target;
  final bool isPinging;
  final VoidCallback onPing;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _MonitorTargetCard({
    required this.target,
    required this.isPinging,
    required this.onPing,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getStatusDotColor() {
    if (!target.isEnabled) return AppColors.textMuted;
    if (target.isHealthy == null) return AppColors.textSecondary;
    return target.isHealthy! ? AppColors.statusSuccess : AppColors.statusServerError;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Never checked';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = _getStatusDotColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: target.isHealthy == false
              ? AppColors.statusServerError.withValues(alpha: 0.5)
              : AppColors.border,
          width: target.isHealthy == false ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status dot, Name, Interval, Switch
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: target.isHealthy == true
                      ? [BoxShadow(color: dotColor.withValues(alpha: 0.5), blurRadius: 6)]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  target.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${target.intervalMinutes}m',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: target.isEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: URL
          Text(
            target.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),

          // Row 3: Metrics & Ping Action
          Row(
            children: [
              if (target.lastStatusCode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.getStatusColor(target.lastStatusCode!).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${target.lastStatusCode}',
                    style: TextStyle(
                      color: AppColors.getStatusColor(target.lastStatusCode!),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (target.lastDurationMs != null) ...[
                Text(
                  '${target.lastDurationMs} ms',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Checked: ${_formatTime(target.lastCheckedAt)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              // Ping Button
              OutlinedButton.icon(
                onPressed: isPinging ? null : onPing,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: isPinging
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                      )
                    : const Icon(Icons.play_arrow, size: 14, color: AppColors.primary),
                label: const Text('Ping', style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
