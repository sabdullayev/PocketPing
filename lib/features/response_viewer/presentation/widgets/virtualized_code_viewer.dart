import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class VirtualizedCodeViewer extends StatefulWidget {
  final String content;
  final List<String>? preSplitLines;
  final bool isJson;

  const VirtualizedCodeViewer({
    super.key,
    required this.content,
    this.preSplitLines,
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

  // Pre-compiled regexes to avoid allocating on every build frame during 120fps scrolling
  static final RegExp _jsonKeyValueRegex = RegExp(r'^(\s*)"([^"]+)"\s*:\s*(.*)$');
  static final RegExp _numberRegex = RegExp(r'^-?[0-9]');

  static const TextStyle _gutterStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    color: AppColors.textMuted,
  );

  static const TextStyle _codeBaseStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle _braceStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AppColors.accent,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _keyStyle = TextStyle(
    color: Color(0xFF82AAFF),
    fontFamily: 'monospace',
    fontSize: 12,
  );

  static const TextStyle _colonStyle = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: 'monospace',
    fontSize: 12,
  );

  static const TextStyle _stringValStyle = TextStyle(
    color: AppColors.statusSuccess,
    fontFamily: 'monospace',
    fontSize: 12,
  );

  static const TextStyle _keywordValStyle = TextStyle(
    color: Color(0xFFC792EA),
    fontFamily: 'monospace',
    fontSize: 12,
  );

  static const TextStyle _numberValStyle = TextStyle(
    color: AppColors.accent,
    fontFamily: 'monospace',
    fontSize: 12,
  );

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
    if (oldWidget.content != widget.content || oldWidget.preSplitLines != widget.preSplitLines) {
      _initLines();
    }
  }

  void _initLines() {
    if (widget.preSplitLines != null && widget.preSplitLines!.isNotEmpty) {
      _lines = widget.preSplitLines!;
    } else if (widget.content.isEmpty) {
      _lines = const [''];
      _contentWidth = 300;
      return;
    } else {
      _lines = widget.content.split('\n');
    }

    // Efficiently estimate maximum line width by sampling up to 50 lines
    int maxLineLength = 0;
    final count = _lines.length;
    final step = math.max(1, count ~/ 50);
    for (int i = 0; i < count; i += step) {
      if (_lines[i].length > maxLineLength) {
        maxLineLength = _lines[i].length;
      }
    }
    for (int i = 0; i < math.min(10, count); i++) {
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

        return Scrollbar(
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
                              style: _gutterStyle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Line content
                          Expanded(
                            child: widget.isJson
                                ? _buildColoredJsonLine(line)
                                : Text(
                                    line,
                                    style: _codeBaseStyle,
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
        style: _braceStyle,
        maxLines: 1,
        softWrap: false,
      );
    }

    final match = _jsonKeyValueRegex.firstMatch(line);
    if (match != null) {
      final indent = match.group(1) ?? '';
      final key = match.group(2) ?? '';
      final rest = match.group(3) ?? '';

      TextStyle valStyle = _codeBaseStyle;
      if (rest.startsWith('"')) {
        valStyle = _stringValStyle;
      } else if (rest.startsWith('true') || rest.startsWith('false') || rest.startsWith('null')) {
        valStyle = _keywordValStyle;
      } else if (_numberRegex.hasMatch(rest)) {
        valStyle = _numberValStyle;
      }

      return RichText(
        maxLines: 1,
        softWrap: false,
        text: TextSpan(
          style: _codeBaseStyle,
          children: [
            TextSpan(text: indent),
            TextSpan(
              text: '"$key"',
              style: _keyStyle,
            ),
            const TextSpan(text: ': ', style: _colonStyle),
            TextSpan(text: rest, style: valStyle),
          ],
        ),
      );
    }

    return Text(
      line,
      style: _codeBaseStyle,
      maxLines: 1,
      softWrap: false,
    );
  }
}
