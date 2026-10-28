import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'environment_variable.dart';

class EnvironmentEntity extends Equatable {
  final String id;
  final String name;
  final List<EnvironmentVariable> variables;
  final bool isSelected;

  EnvironmentEntity({
    String? id,
    required this.name,
    List<EnvironmentVariable>? variables,
    this.isSelected = false,
  })  : id = id ?? const Uuid().v4(),
        variables = variables ?? const [];

  const EnvironmentEntity.raw({
    required this.id,
    required this.name,
    required this.variables,
    required this.isSelected,
  });

  EnvironmentEntity copyWith({
    String? id,
    String? name,
    List<EnvironmentVariable>? variables,
    bool? isSelected,
  }) {
    return EnvironmentEntity.raw(
      id: id ?? this.id,
      name: name ?? this.name,
      variables: variables ?? this.variables,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, name, variables, isSelected];
}
