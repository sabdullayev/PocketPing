import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../environments/presentation/widgets/variable_autocomplete_field.dart';
import '../../domain/entities/request_body.dart';
import 'fullscreen_body_editor_dialog.dart';

class BodyTabView extends StatefulWidget {
  final RequestBody body;
  final bool isKeyboardOpen;
  final ValueChanged<RequestBodyType> onTypeChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onFormatJson;

  const BodyTabView({
    super.key,
    required this.body,
    this.isKeyboardOpen = false,
    required this.onTypeChanged,
    required this.onContentChanged,
    required this.onFormatJson,
  });

  @override
  State<BodyTabView> createState() => _BodyTabViewState();
}

class _BodyTabViewState extends State<BodyTabView> {
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.body.rawContent);
  }

  @override
  void didUpdateWidget(covariant BodyTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.body.rawContent != oldWidget.body.rawContent &&
        widget.body.rawContent != _contentController.text) {
      _contentController.text = widget.body.rawContent;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _insertSnippet(String snippet) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = text.replaceRange(
      selection.start >= 0 ? selection.start : text.length,
      selection.end >= 0 ? selection.end : text.length,
      snippet,
    );
    _contentController.text = newText;
    widget.onContentChanged(newText);
  }

  void _openFullscreen() {
    FullscreenBodyEditorDialog.show(
      context: context,
      initialContent: _contentController.text,
      type: widget.body.type,
      onSaved: (val) {
        _contentController.text = val;
        widget.onContentChanged(val);
      },
      onFormatJson: widget.onFormatJson,
    );
  }

  Widget _snippetChip(String label, String code) {
    return InkWell(
      onTap: () => _insertSnippet(code),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.accent,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = widget.isKeyboardOpen || MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      children: [
        // Row 1: Type Switcher Chips (Clean & isolated; hidden when typing to maximize screen height)
        if (!isKeyboardOpen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...RequestBodyType.values.where((t) => t != RequestBodyType.formData).map((type) {
                          final isSelected = widget.body.type == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              label: Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              onSelected: (_) => widget.onTypeChanged(type),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (widget.body.type == RequestBodyType.none)
          const Expanded(
            child: Center(
              child: Text(
                'This request does not have a body',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else ...[
          // Row 2: Editor Toolbar (Quick snippets on Left, Actions [Beautify & Expand] on Right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              children: [
                // Left: Quick Snippets (scrollable horizontally if screen is small)
                if (widget.body.type == RequestBodyType.json)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('Quick: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          _snippetChip('{}', '{\n  \n}'),
                          const SizedBox(width: 5),
                          _snippetChip('[]', '[\n  \n]'),
                          const SizedBox(width: 5),
                          _snippetChip('"key": "val"', '"key": "value"'),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 6),
                // Right: Action Buttons (Fills the space beautifully!)
                if (widget.body.type == RequestBodyType.json) ...[
                  _actionButton(
                    icon: Icons.auto_fix_high,
                    label: 'Beautify',
                    onTap: widget.onFormatJson,
                  ),
                  const SizedBox(width: 6),
                ],
                _actionButton(
                  icon: Icons.fullscreen,
                  label: 'Expand',
                  onTap: _openFullscreen,
                ),
                if (isKeyboardOpen) ...[
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.keyboard_hide,
                    label: 'Done',
                    color: AppColors.textMuted,
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ],
              ],
            ),
          ),
          // Editor Field (Spacious, fills all available height)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: VariableAutocompleteField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: widget.onContentChanged,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.body.type == RequestBodyType.json
                      ? '{\n  "name": "value"\n}'
                      : 'Enter payload...',
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
