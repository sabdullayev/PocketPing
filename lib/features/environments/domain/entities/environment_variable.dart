import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class EnvironmentVariable extends Equatable {
  final String id;
  final String key;
  final String value;
  final bool isEnabled;

  EnvironmentVariable({
    String? id,
    required this.key,
    required this.value,
    this.isEnabled = true,
  }) : id = id ?? const Uuid().v4();

  const EnvironmentVariable.raw({
    required this.id,
    required this.key,
    required this.value,
    required this.isEnabled,
  });

  EnvironmentVariable copyWith({
    String? id,
    String? key,
    String? value,
    bool? isEnabled,
  }) {
    return EnvironmentVariable.raw(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, key, value, isEnabled];
}
