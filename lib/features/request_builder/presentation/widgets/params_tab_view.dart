import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../environments/presentation/widgets/variable_autocomplete_field.dart';
import '../../domain/entities/key_value_param.dart';

class ParamsTabView extends StatelessWidget {
  final List<KeyValueParam> queryParams;
  final VoidCallback onAddParam;
  final Function(String id) onToggleParam;
  final Function(String id, String key, String value) onUpdateParam;
  final Function(String id) onRemoveParam;

  const ParamsTabView({
    super.key,
    required this.queryParams,
    required this.onAddParam,
    required this.onToggleParam,
    required this.onUpdateParam,
    required this.onRemoveParam,
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
                'Query Parameters (${queryParams.length})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: onAddParam,
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: const Text(
                  'Add Param',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (queryParams.isEmpty)
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No query parameters. Tap "+ Add Param" or type in URL (?key=val)',
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
              itemCount: queryParams.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final param = queryParams[index];
                return _ParamRow(
                  key: ValueKey(param.id),
                  param: param,
                  onToggle: () => onToggleParam(param.id),
                  onUpdate: (key, val) => onUpdateParam(param.id, key, val),
                  onRemove: () => onRemoveParam(param.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ParamRow extends StatefulWidget {
  final KeyValueParam param;
  final VoidCallback onToggle;
  final Function(String key, String val) onUpdate;
  final VoidCallback onRemove;

  const _ParamRow({
    super.key,
    required this.param,
    required this.onToggle,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_ParamRow> createState() => _ParamRowState();
}

class _ParamRowState extends State<_ParamRow> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.param.key);
    _valueController = TextEditingController(text: widget.param.value);
  }

  @override
  void didUpdateWidget(covariant _ParamRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.param.key != widget.param.key && _keyController.text != widget.param.key) {
      _keyController.text = widget.param.key;
    }
    if (oldWidget.param.value != widget.param.value && _valueController.text != widget.param.value) {
      _valueController.text = widget.param.value;
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
          color: widget.param.isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.param.isEnabled,
            activeColor: AppColors.primary,
            onChanged: (_) => widget.onToggle(),
          ),
          Expanded(
            flex: 2,
            child: VariableAutocompleteField(
              controller: _keyController,
              onChanged: (_) => _notifyChange(),
              style: TextStyle(
                fontSize: 13,
                color: widget.param.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              decoration: const InputDecoration(
                hintText: 'Parameter key',
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
            child: VariableAutocompleteField(
              controller: _valueController,
              onChanged: (_) => _notifyChange(),
              style: TextStyle(
                fontSize: 13,
                color: widget.param.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
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
