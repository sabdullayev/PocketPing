import '../../domain/entities/environment_entity.dart';
import '../../domain/entities/environment_variable.dart';

class EnvironmentModel {
  final String id;
  final String name;
  final List<Map<String, dynamic>> variables;
  final bool isSelected;

  const EnvironmentModel({
    required this.id,
    required this.name,
    required this.variables,
    required this.isSelected,
  });

  factory EnvironmentModel.fromEntity(EnvironmentEntity entity) {
    return EnvironmentModel(
      id: entity.id,
      name: entity.name,
      variables: entity.variables
          .map((v) => {
                'id': v.id,
                'key': v.key,
                'value': v.value,
                'isEnabled': v.isEnabled,
              })
          .toList(),
      isSelected: entity.isSelected,
    );
  }

  EnvironmentEntity toEntity() {
    return EnvironmentEntity.raw(
      id: id,
      name: name,
      variables: variables
          .map((v) => EnvironmentVariable.raw(
                id: v['id']?.toString() ?? '',
                key: v['key']?.toString() ?? '',
                value: v['value']?.toString() ?? '',
                isEnabled: v['isEnabled'] == true,
              ))
          .toList(),
      isSelected: isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'variables': variables,
      'isSelected': isSelected,
    };
  }

  factory EnvironmentModel.fromMap(Map<dynamic, dynamic> map) {
    final varsRaw = map['variables'] as List<dynamic>? ?? [];
    return EnvironmentModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Environment',
      variables: varsRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      isSelected: map['isSelected'] == true,
    );
  }
}
