import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum HttpMethod {
  get('GET', AppColors.methodGet),
  post('POST', AppColors.methodPost),
  put('PUT', AppColors.methodPut),
  delete('DELETE', AppColors.methodDelete),
  patch('PATCH', AppColors.methodPatch),
  head('HEAD', AppColors.methodHead);

  final String label;
  final Color color;

  const HttpMethod(this.label, this.color);

  static HttpMethod fromString(String method) {
    switch (method.toUpperCase().trim()) {
      case 'POST':
        return HttpMethod.post;
      case 'PUT':
        return HttpMethod.put;
      case 'DELETE':
        return HttpMethod.delete;
      case 'PATCH':
        return HttpMethod.patch;
      case 'HEAD':
        return HttpMethod.head;
      case 'GET':
      default:
        return HttpMethod.get;
    }
  }
}
