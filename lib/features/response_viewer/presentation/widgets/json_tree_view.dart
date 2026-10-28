import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class JsonTreeView extends StatefulWidget {
  final dynamic data;

  const JsonTreeView({super.key, required this.data});

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _FlatTreeNode {
  final String path;
  final String? keyName;
  final dynamic value;
  final int depth;
  final bool isExpandable;
  final bool isObject; // true for Map, false for List
  final int childCount;
  final bool isClosingBracket;
  final String closingSymbol;

  const _FlatTreeNode({
    required this.path,
    this.keyName,
    this.value,
    required this.depth,
    required this.isExpandable,
    this.isObject = false,
    this.childCount = 0,
    this.isClosingBracket = false,
    this.closingSymbol = '',
  });
}

class _JsonTreeViewState extends State<JsonTreeView> {
  final Set<String> _expandedPaths = {};
  List<_FlatTreeNode> _visibleNodes = [];

  @override
  void initState() {
    super.initState();
    _initDefaultExpansion();
    _rebuildFlatList();
  }

  @override
  void didUpdateWidget(covariant JsonTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _expandedPaths.clear();
      _initDefaultExpansion();
      _rebuildFlatList();
    }
  }

  void _initDefaultExpansion() {
    final data = widget.data;
    if (data == null) return;

    // Root is expanded
    _expandedPaths.add('');

    // Expand top-level keys if reasonable size
    if (data is Map) {
      for (final entry in data.entries) {
        final k = entry.key.toString();
        final v = entry.value;
        if (v is Map && v.length <= 15) {
          _expandedPaths.add(k);
        } else if (v is List) {
          // Expand array container so items [0], [1], ... are visible,
          // but do NOT expand individual items by default to keep 500+ items instant
          _expandedPaths.add(k);
        }
      }
    }
  }

  void _rebuildFlatList() {
    final data = widget.data;
    if (data == null) {
      setState(() => _visibleNodes = const []);
      return;
    }

    final List<_FlatTreeNode> list = [];
    _flatten(data, '', null, 0, list);
    setState(() => _visibleNodes = list);
  }

  void _flatten(dynamic node, String path, String? keyName, int depth, List<_FlatTreeNode> list) {
    if (node is Map) {
      final isExpanded = _expandedPaths.contains(path);
      list.add(_FlatTreeNode(
        path: path,
        keyName: keyName,
        value: node,
        depth: depth,
        isExpandable: true,
        isObject: true,
        childCount: node.length,
      ));

      if (isExpanded) {
        for (final entry in node.entries) {
          final k = entry.key.toString();
          final childPath = path.isEmpty ? k : '$path.$k';
          _flatten(entry.value, childPath, k, depth + 1, list);
        }
        list.add(_FlatTreeNode(
          path: '${path}_close',
          depth: depth,
          isExpandable: false,
          isClosingBracket: true,
          closingSymbol: '}',
        ));
      }
    } else if (node is List) {
      final isExpanded = _expandedPaths.contains(path);
      list.add(_FlatTreeNode(
        path: path,
        keyName: keyName,
        value: node,
        depth: depth,
        isExpandable: true,
        isObject: false,
        childCount: node.length,
      ));

      if (isExpanded) {
        for (int i = 0; i < node.length; i++) {
          final childPath = '$path[$i]';
          _flatten(node[i], childPath, '[$i]', depth + 1, list);
        }
        list.add(_FlatTreeNode(
          path: '${path}_close',
          depth: depth,
          isExpandable: false,
          isClosingBracket: true,
          closingSymbol: ']',
        ));
      }
    } else {
      // Primitive
      list.add(_FlatTreeNode(
        path: path,
        keyName: keyName,
        value: node,
        depth: depth,
        isExpandable: false,
      ));
    }
  }

  void _toggleNode(String path) {
    if (_expandedPaths.contains(path)) {
      _expandedPaths.remove(path);
    } else {
      _expandedPaths.add(path);
    }
    _rebuildFlatList();
  }

  void _expandAll() {
    void collectPaths(dynamic node, String path) {
      if (node is Map) {
        _expandedPaths.add(path);
        for (final entry in node.entries) {
          final k = entry.key.toString();
          final childPath = path.isEmpty ? k : '$path.$k';
          collectPaths(entry.value, childPath);
        }
      } else if (node is List) {
        _expandedPaths.add(path);
        // Cap recursive expand for large lists to prevent excessive rows
        final limit = math.min(node.length, 50);
        for (int i = 0; i < limit; i++) {
          collectPaths(node[i], '$path[$i]');
        }
      }
    }

    collectPaths(widget.data, '');
    _rebuildFlatList();
  }

  void _collapseAll() {
    _expandedPaths.clear();
    _rebuildFlatList();
  }

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
                        content: Text('Copied value to clipboard'),
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
    if (widget.data == null) {
      return const Center(
        child: Text('Null or empty JSON', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return Column(
      children: [
        // Tree Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          color: AppColors.surface.withValues(alpha: 0.5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_visibleNodes.length} nodes visible',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _expandAll,
                icon: const Icon(Icons.unfold_more, size: 14, color: AppColors.primary),
                label: const Text('Expand', style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _collapseAll,
                icon: const Icon(Icons.unfold_less, size: 14, color: AppColors.textMuted),
                label: const Text('Collapse', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // 120fps Virtualized Tree List
        Expanded(
          child: ListView.builder(
            itemCount: _visibleNodes.length,
            itemExtent: 26.0,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemBuilder: (context, index) {
              final node = _visibleNodes[index];
              return _buildNodeRow(node);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNodeRow(_FlatTreeNode node) {
    final indent = (node.depth * 14.0) + 8.0;

    if (node.isClosingBracket) {
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            node.closingSymbol,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final isExpanded = _expandedPaths.contains(node.path);

    return InkWell(
      onTap: node.isExpandable ? () => _toggleNode(node.path) : null,
      onLongPress: () => _showActionMenu(context, node.path, node.value),
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: 8),
        child: Row(
          children: [
            if (node.isExpandable) ...[
              Icon(
                isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ] else ...[
              const SizedBox(width: 18),
            ],
            if (node.keyName != null) ...[
              Text(
                node.keyName!.startsWith('[') ? '${node.keyName}: ' : '"${node.keyName}": ',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (node.isExpandable) ...[
              Text(
                node.isObject
                    ? (isExpanded ? '{' : '{ ${node.childCount} keys }')
                    : (isExpanded ? '[' : '[ ${node.childCount} items ]'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ] else ...[
              _buildPrimitiveValue(node.value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimitiveValue(dynamic val) {
    Color valColor = AppColors.methodGet;
    String valString = val.toString();

    if (val == null) {
      valColor = const Color(0xFFC792EA);
      valString = 'null';
    } else if (val is bool) {
      valColor = const Color(0xFFC792EA);
    } else if (val is num) {
      valColor = AppColors.accent;
    } else if (val is String) {
      valColor = AppColors.statusSuccess;
      valString = '"$val"';
    }

    return Expanded(
      child: Text(
        valString,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: valColor,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
