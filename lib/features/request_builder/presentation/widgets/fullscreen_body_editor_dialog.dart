import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../environments/presentation/widgets/variable_autocomplete_field.dart';
import '../../domain/entities/request_body.dart';

class FullscreenBodyEditorDialog extends StatefulWidget {
  final String initialContent;
  final RequestBodyType type;
  final ValueChanged<String> onSaved;
  final VoidCallback onFormatJson;

  const FullscreenBodyEditorDialog({
    super.key,
    required this.initialContent,
    required this.type,
    required this.onSaved,
    required this.onFormatJson,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialContent,
    required RequestBodyType type,
    required ValueChanged<String> onSaved,
    required VoidCallback onFormatJson,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullscreenBodyEditorDialog(
          initialContent: initialContent,
          type: type,
          onSaved: onSaved,
          onFormatJson: onFormatJson,
        ),
      ),
    );
  }

  @override
  State<FullscreenBodyEditorDialog> createState() => _FullscreenBodyEditorDialogState();
}

class _FullscreenBodyEditorDialogState extends State<FullscreenBodyEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertSnippet(String snippet) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(
      selection.start >= 0 ? selection.start : text.length,
      selection.end >= 0 ? selection.end : text.length,
      snippet,
    );
    _controller.text = newText;
    widget.onSaved(newText);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Body (${widget.type.label})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (widget.type == RequestBodyType.json)
            IconButton(
              icon: const Icon(Icons.auto_fix_high, color: AppColors.accent, size: 20),
              tooltip: 'Format / Beautify JSON',
              onPressed: () {
                widget.onFormatJson();
              },
            ),
          TextButton.icon(
            onPressed: () {
              widget.onSaved(_controller.text);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, color: AppColors.primary, size: 18),
            label: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Snippets Toolbar
            if (widget.type == RequestBodyType.json)
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Text('Quick: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    _snippetChip('{}', '{\n  \n}'),
                    const SizedBox(width: 6),
                    _snippetChip('[]', '[\n  \n]'),
                    const SizedBox(width: 6),
                    _snippetChip('"key": "val"', '"key": "value"'),
                    const Spacer(),
                    InkWell(
                      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Icon(Icons.keyboard_hide, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            // Fullscreen Variable-Aware Code Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: VariableAutocompleteField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: widget.onSaved,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.type == RequestBodyType.json
                        ? '{\n  "name": "value"\n}'
                        : 'Enter payload...',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
