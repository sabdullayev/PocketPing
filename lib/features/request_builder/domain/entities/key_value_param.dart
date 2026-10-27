import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class KeyValueParam extends Equatable {
  final String id;
  final String key;
  final String value;
  final bool isEnabled;

  KeyValueParam({
    String? id,
    this.key = '',
    this.value = '',
    this.isEnabled = true,
  }) : id = id ?? const Uuid().v4();

  const KeyValueParam.raw({
    required this.id,
    required this.key,
    required this.value,
    required this.isEnabled,
  });

  KeyValueParam copyWith({
    String? id,
    String? key,
    String? value,
    bool? isEnabled,
  }) {
    return KeyValueParam.raw(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, key, value, isEnabled];
}
