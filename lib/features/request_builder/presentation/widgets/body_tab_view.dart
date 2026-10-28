import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../environments/presentation/widgets/variable_autocomplete_field.dart';
import '../../domain/entities/request_body.dart';

class BodyTabView extends StatefulWidget {
  final RequestBody body;
  final ValueChanged<RequestBodyType> onTypeChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onFormatJson;

  const BodyTabView({
    super.key,
    required this.body,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Type Switcher Row (Scrollable to prevent any RenderFlex overflow on small screens)
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
              if (widget.body.type == RequestBodyType.json)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: widget.onFormatJson,
                  icon: const Icon(Icons.auto_fix_high, size: 14, color: AppColors.accent),
                  label: const Text(
                    'Beautify',
                    style: TextStyle(color: AppColors.accent, fontSize: 12),
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
          // Quick JSON Snippets
          if (widget.body.type == RequestBodyType.json)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('Quick: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          _snippetChip('{}', '{\n  \n}'),
                          const SizedBox(width: 6),
                          _snippetChip('[]', '[\n  \n]'),
                          const SizedBox(width: 6),
                          _snippetChip('"key": "val"', '"key": "value"'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_hide, size: 14, color: AppColors.textMuted),
                          SizedBox(width: 4),
                          Text('Done', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Editor Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
