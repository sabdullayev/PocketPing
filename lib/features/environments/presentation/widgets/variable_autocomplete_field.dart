import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/environment_variable.dart';
import '../bloc/environments_bloc.dart';
import '../bloc/environments_state.dart';

class VariableAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool obscureText;

  const VariableAutocompleteField({
    super.key,
    required this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.maxLines = 1,
    this.expands = false,
    this.textAlignVertical,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.obscureText = false,
  });

  @override
  State<VariableAutocompleteField> createState() => _VariableAutocompleteFieldState();
}

class _VariableAutocompleteFieldState extends State<VariableAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late final FocusNode _focusNode;
  bool _internalFocusNode = false;
  bool _isDoubleBrace = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }

    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _hideOverlay();
    }
  }

  void _handleTextChange() {
    if (!_focusNode.hasFocus) {
      _hideOverlay();
      return;
    }

    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
    final textBefore = text.substring(0, cursor);

    final match = RegExp(r'\{(\{)?([a-zA-Z0-9_]*)$').firstMatch(textBefore);
    if (match != null) {
      final isDouble = match.group(1) != null;
      final query = (match.group(2) ?? '').toLowerCase();
      _isDoubleBrace = isDouble;

      final envState = context.read<EnvironmentsBloc>().state;
      List<EnvironmentVariable> vars = [];
      if (envState is EnvironmentsLoadedState && envState.selectedEnvironment != null) {
        vars = envState.selectedEnvironment!.variables
            .where((v) => v.isEnabled && v.key.trim().isNotEmpty && v.key.toLowerCase().contains(query))
            .toList();
      }

      if (vars.isNotEmpty) {
        _showOverlay(vars);
      } else {
        _hideOverlay();
      }
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay(List<EnvironmentVariable> vars) {
    _hideOverlay();
    if (!mounted) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final size = renderBox?.size ?? Size.zero;
        final screenWidth = MediaQuery.of(ctx).size.width;

        return Positioned(
          width: screenWidth > 400 ? 360 : screenWidth - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(0, size.height > 0 ? 4 : 28),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              color: AppColors.surfaceElevated,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: vars.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (ctx, i) {
                    final v = vars[i];
                    return InkWell(
                      onTap: () => _insertVariable(v.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _isDoubleBrace ? '{{${v.key}}}' : '{${v.key}}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                v.value,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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

    overlay.insert(_overlayEntry!);
  }

  void _insertVariable(String key) {
    final text = widget.controller.text;
    final cursor = widget.controller.selection.baseOffset >= 0
        ? widget.controller.selection.baseOffset
        : text.length;
    final textBefore = text.substring(0, cursor);
    final textAfter = text.substring(cursor);

    final match = RegExp(r'\{(\{)?([a-zA-Z0-9_]*)$').firstMatch(textBefore);
    if (match != null) {
      final startIndex = match.start;
      final inserted = _isDoubleBrace ? '{{$key}}' : '{$key}';
      final newText = textBefore.substring(0, startIndex) + inserted + textAfter;
      final newCursor = startIndex + inserted.length;

      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
      widget.onChanged?.call(newText);
    }
    _hideOverlay();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: widget.style,
        maxLines: widget.maxLines,
        expands: widget.expands,
        textAlignVertical: widget.textAlignVertical,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: widget.decoration,
      ),
    );
  }
}
