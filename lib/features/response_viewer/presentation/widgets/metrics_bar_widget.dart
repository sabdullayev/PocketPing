import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/http_response_entity.dart';

class MetricsBarWidget extends StatelessWidget {
  final HttpResponseEntity response;
  final VoidCallback? onClose;

  const MetricsBarWidget({
    super.key,
    required this.response,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(response.statusCode);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Code Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${response.statusCode} ${response.statusMessage}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Response Time Badge
            _MetricBadge(
              icon: Icons.timer_outlined,
              text: response.formattedDuration,
              color: response.durationMs > 1000 ? AppColors.statusClientError : AppColors.statusSuccess,
            ),
            const SizedBox(width: 6),
            // Response Size Badge
            _MetricBadge(
              icon: Icons.inventory_2_outlined,
              text: response.formattedSize,
              color: AppColors.accent,
            ),
            if (onClose != null) ...[
              const SizedBox(width: 8),
              InkWell(
                key: const Key('close_response_button'),
                onTap: onClose,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.statusClientError.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.statusClientError.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.close, size: 15, color: AppColors.statusClientError),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetricBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
