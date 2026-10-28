import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class VirtualizedCodeViewer extends StatefulWidget {
  final String content;
  final bool isJson;

  const VirtualizedCodeViewer({
    super.key,
    required this.content,
    this.isJson = false,
  });

  @override
  State<VirtualizedCodeViewer> createState() => _VirtualizedCodeViewerState();
}

class _VirtualizedCodeViewerState extends State<VirtualizedCodeViewer> {
  late List<String> _lines;
  late double _contentWidth;
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  static const double _lineHeight = 22.0;
  static const double _charWidth = 7.5;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
    _initLines();
  }

  @override
  void didUpdateWidget(covariant VirtualizedCodeViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _initLines();
    }
  }

  void _initLines() {
    if (widget.content.isEmpty) {
      _lines = [''];
      _contentWidth = 300;
      return;
    }

    _lines = widget.content.split('\n');

    // Efficiently estimate maximum line width by sampling
    int maxLineLength = 0;
    final step = math.max(1, _lines.length ~/ 200);
    for (int i = 0; i < _lines.length; i += step) {
      if (_lines[i].length > maxLineLength) {
        maxLineLength = _lines[i].length;
      }
    }
    for (int i = 0; i < math.min(15, _lines.length); i++) {
      if (_lines[i].length > maxLineLength) maxLineLength = _lines[i].length;
    }

    final calculatedWidth = (maxLineLength * _charWidth) + 90.0;
    _contentWidth = math.max(360.0, calculatedWidth);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _copyLine(int lineNumber, String line) {
    Clipboard.setData(ClipboardData(text: line));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Line $lineNumber copied'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty || (_lines.length == 1 && _lines.first.isEmpty)) {
      return const Center(
        child: Text('Empty content', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      );
    }

    final maxLineNumberDigits = _lines.length.toString().length;
    final lineNumberWidth = math.max(30.0, maxLineNumberDigits * 8.5 + 16.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = math.max(constraints.maxWidth, _contentWidth);

        return SelectionArea(
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: totalWidth,
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _verticalController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: _lines.length,
                    itemExtent: _lineHeight,
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      final lineNumber = index + 1;

                      return InkWell(
                        onLongPress: () => _copyLine(lineNumber, line),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Line number gutter
                            Container(
                              width: lineNumberWidth,
                              padding: const EdgeInsets.only(right: 10),
                              alignment: Alignment.centerRight,
                              color: AppColors.surface.withValues(alpha: 0.35),
                              child: Text(
                                '$lineNumber',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Line content
                            Expanded(
                              child: widget.isJson
                                  ? _buildColoredJsonLine(line)
                                  : Text(
                                      line,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.visible,
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColoredJsonLine(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('{') ||
        trimmed.startsWith('}') ||
        trimmed.startsWith('[') ||
        trimmed.startsWith(']')) {
      return Text(
        line,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        softWrap: false,
      );
    }

    final match = RegExp(r'^(\s*)"([^"]+)"\s*:\s*(.*)$').firstMatch(line);
    if (match != null) {
      final indent = match.group(1) ?? '';
      final key = match.group(2) ?? '';
      final rest = match.group(3) ?? '';

      Color valColor = AppColors.textPrimary;
      if (rest.startsWith('"')) {
        valColor = AppColors.statusSuccess;
      } else if (rest.startsWith('true') || rest.startsWith('false') || rest.startsWith('null')) {
        valColor = const Color(0xFFC792EA);
      } else if (RegExp(r'^-?[0-9]').hasMatch(rest)) {
        valColor = AppColors.accent;
      }

      return RichText(
        maxLines: 1,
        softWrap: false,
        text: TextSpan(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          children: [
            TextSpan(text: indent),
            TextSpan(
              text: '"$key"',
              style: const TextStyle(color: Color(0xFF82AAFF)),
            ),
            const TextSpan(text: ': ', style: TextStyle(color: AppColors.textSecondary)),
            TextSpan(text: rest, style: TextStyle(color: valColor)),
          ],
        ),
      );
    }

    return Text(
      line,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      softWrap: false,
    );
  }
}
