import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/key_value_param.dart';

class HeadersTabView extends StatelessWidget {
  final List<KeyValueParam> headers;
  final VoidCallback onAddHeader;
  final Function(String id) onToggleHeader;
  final Function(String id, String key, String value) onUpdateHeader;
  final Function(String id) onRemoveHeader;

  const HeadersTabView({
    super.key,
    required this.headers,
    required this.onAddHeader,
    required this.onToggleHeader,
    required this.onUpdateHeader,
    required this.onRemoveHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HTTP Headers (${headers.length})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: onAddHeader,
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: const Text(
                  'Add Header',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (headers.isEmpty)
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No custom headers configured. Tap "+ Add Header"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: headers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final header = headers[index];
                return _HeaderRow(
                  key: ValueKey(header.id),
                  header: header,
                  onToggle: () => onToggleHeader(header.id),
                  onUpdate: (key, val) => onUpdateHeader(header.id, key, val),
                  onRemove: () => onRemoveHeader(header.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HeaderRow extends StatefulWidget {
  final KeyValueParam header;
  final VoidCallback onToggle;
  final Function(String key, String val) onUpdate;
  final VoidCallback onRemove;

  const _HeaderRow({
    super.key,
    required this.header,
    required this.onToggle,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<_HeaderRow> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.header.key);
    _valueController = TextEditingController(text: widget.header.value);
  }

  @override
  void didUpdateWidget(covariant _HeaderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.header.key != widget.header.key && _keyController.text != widget.header.key) {
      _keyController.text = widget.header.key;
    }
    if (oldWidget.header.value != widget.header.value && _valueController.text != widget.header.value) {
      _valueController.text = widget.header.value;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onUpdate(_keyController.text, _valueController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.header.isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.header.isEnabled,
            activeColor: AppColors.primary,
            onChanged: (_) => widget.onToggle(),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _keyController,
              onChanged: (_) => _notifyChange(),
              style: TextStyle(
                fontSize: 13,
                color: widget.header.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              decoration: const InputDecoration(
                hintText: 'Header name (e.g. Accept)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: AppColors.border),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _valueController,
              onChanged: (_) => _notifyChange(),
              style: TextStyle(
                fontSize: 13,
                color: widget.header.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              decoration: const InputDecoration(
                hintText: 'Value',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
