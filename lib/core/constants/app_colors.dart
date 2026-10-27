import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF161922);
  static const Color card = Color(0xFF1E2230);
  static const Color surfaceElevated = Color(0xFF262B3D);
  static const Color border = Color(0xFF2E344A);
  static const Color borderLight = Color(0xFF3F4765);

  // Brand & Accents
  static const Color primary = Color(0xFFFF6C37); // Postman-like vibrant orange
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color accent = Color(0xFF00D2FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F4FC);
  static const Color textSecondary = Color(0xFF9AA4BF);
  static const Color textMuted = Color(0xFF646E89);

  // HTTP Method Colors
  static const Color methodGet = Color(0xFF00E676);    // Vibrant Green
  static const Color methodPost = Color(0xFFFF9100);   // Vibrant Amber/Orange
  static const Color methodPut = Color(0xFF2979FF);    // Vibrant Blue
  static const Color methodDelete = Color(0xFFFF5252); // Vibrant Red
  static const Color methodPatch = Color(0xFFAB47BC);  // Vibrant Purple
  static const Color methodHead = Color(0xFF78909C);   // Blue Grey

  // Status Code Colors
  static const Color statusSuccess = Color(0xFF00E676); // 2xx
  static const Color statusRedirect = Color(0xFF00B0FF); // 3xx
  static const Color statusClientError = Color(0xFFFFAB00); // 4xx
  static const Color statusServerError = Color(0xFFFF3D00); // 5xx

  static Color getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return statusSuccess;
    if (statusCode >= 300 && statusCode < 400) return statusRedirect;
    if (statusCode >= 400 && statusCode < 500) return statusClientError;
    if (statusCode >= 500) return statusServerError;
    return textSecondary;
  }
}
