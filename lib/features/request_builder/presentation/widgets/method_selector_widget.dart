import 'package:flutter/material.dart';
import '../../domain/entities/http_method.dart';

class MethodSelectorWidget extends StatelessWidget {
  final HttpMethod currentMethod;
  final ValueChanged<HttpMethod> onMethodChanged;

  const MethodSelectorWidget({
    super.key,
    required this.currentMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: currentMethod.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentMethod.color.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HttpMethod>(
          value: currentMethod,
          isDense: true,
          dropdownColor: const Color(0xFF1E2230),
          icon: Icon(Icons.arrow_drop_down, color: currentMethod.color),
          items: HttpMethod.values.map((method) {
            return DropdownMenuItem<HttpMethod>(
              value: method,
              child: Text(
                method.label,
                style: TextStyle(
                  color: method.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (method) {
            if (method != null) {
              onMethodChanged(method);
            }
          },
        ),
      ),
    );
  }
}
