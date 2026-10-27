import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class AuthTabView extends StatefulWidget {
  final String? bearerToken;
  final ValueChanged<String> onTokenChanged;

  const AuthTabView({
    super.key,
    required this.bearerToken,
    required this.onTokenChanged,
  });

  @override
  State<AuthTabView> createState() => _AuthTabViewState();
}

class _AuthTabViewState extends State<AuthTabView> {
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bearerToken ?? '');
  }

  @override
  void didUpdateWidget(covariant AuthTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bearerToken != oldWidget.bearerToken && widget.bearerToken != _controller.text) {
      _controller.text = widget.bearerToken ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!.trim();
      widget.onTokenChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bearer Token Authorization',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.paste, size: 16, color: AppColors.primary),
                label: const Text(
                  'Paste',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'The token will be sent automatically as header: Authorization: Bearer <token>',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscureText,
            maxLines: _obscureText ? 1 : 4,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            onChanged: widget.onTokenChanged,
            decoration: InputDecoration(
              hintText: 'eyJh... or paste your API token here',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        _controller.clear();
                        widget.onTokenChanged('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
