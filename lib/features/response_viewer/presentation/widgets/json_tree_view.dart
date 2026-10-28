import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class JsonTreeView extends StatelessWidget {
  final dynamic data;

  const JsonTreeView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(
        child: Text('Null or empty JSON', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: _JsonNodeWidget(
        nodeKey: null,
        value: data,
        path: '',
        isLast: true,
      ),
    );
  }
}

class _JsonNodeWidget extends StatefulWidget {
  final String? nodeKey;
  final dynamic value;
  final String path;
  final bool isLast;

  const _JsonNodeWidget({
    required this.nodeKey,
    required this.value,
    required this.path,
    this.isLast = false,
  });

  @override
  State<_JsonNodeWidget> createState() => _JsonNodeWidgetState();
}

class _JsonNodeWidgetState extends State<_JsonNodeWidget> {
  bool _isExpanded = true;

  void _showActionMenu(BuildContext context, String path, dynamic value) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    path.isEmpty ? 'Root' : path,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                const Divider(color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.route, color: AppColors.primary, size: 20),
                  title: const Text('Copy JSON Path', style: TextStyle(fontSize: 14)),
                  subtitle: Text(path, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: path));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied path: $path'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.surfaceElevated,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy, color: AppColors.accent, size: 20),
                  title: const Text('Copy Value', style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    value.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value.toString()));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied value: ${value.toString()}'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.surfaceElevated,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final val = widget.value;

    if (val is Map) {
      return _buildObjectNode(val);
    } else if (val is List) {
      return _buildArrayNode(val);
    } else {
      return _buildPrimitiveNode(val);
    }
  }

  Widget _buildObjectNode(Map map) {
    final count = map.length;
    final keys = map.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          onLongPress: widget.path.isNotEmpty ? () => _showActionMenu(context, widget.path, map) : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                if (widget.nodeKey != null) ...[
                  Text(
                    '"${widget.nodeKey}": ',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                Text(
                  _isExpanded ? '{' : '{ $count items }',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(keys.length, (i) {
                final k = keys[i].toString();
                final childPath = widget.path.isEmpty ? k : '${widget.path}.$k';
                return _JsonNodeWidget(
                  nodeKey: k,
                  value: map[keys[i]],
                  path: childPath,
                  isLast: i == keys.length - 1,
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              widget.isLast ? '}' : '},',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArrayNode(List list) {
    final count = list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          onLongPress: widget.path.isNotEmpty ? () => _showActionMenu(context, widget.path, list) : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                if (widget.nodeKey != null) ...[
                  Text(
                    '"${widget.nodeKey}": ',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                Text(
                  _isExpanded ? '[' : '[ $count items ]',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(list.length, (i) {
                final childPath = '${widget.path}[$i]';
                return _JsonNodeWidget(
                  nodeKey: null,
                  value: list[i],
                  path: childPath,
                  isLast: i == list.length - 1,
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              widget.isLast ? ']' : '],',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimitiveNode(dynamic val) {
    Color valColor = AppColors.methodGet;
    String valString = val.toString();

    if (val is String) {
      valColor = const Color(0xFF98C379); // String green
      valString = '"$val"';
    } else if (val is num) {
      valColor = const Color(0xFFD19A66); // Number orange
    } else if (val is bool) {
      valColor = const Color(0xFFC678DD); // Bool purple
    } else if (val == null) {
      valColor = AppColors.textMuted;
      valString = 'null';
    }

    final lineSuffix = widget.isLast ? '' : ',';

    return InkWell(
      onLongPress: () => _showActionMenu(context, widget.path, val),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.nodeKey != null) ...[
              Text(
                '"${widget.nodeKey}": ',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            Flexible(
              child: Text(
                '$valString$lineSuffix',
                style: TextStyle(
                  color: valColor,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
