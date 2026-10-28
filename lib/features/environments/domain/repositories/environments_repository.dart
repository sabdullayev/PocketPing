import '../entities/environment_entity.dart';

abstract class EnvironmentsRepository {
  Future<List<EnvironmentEntity>> getEnvironments();
  Future<void> saveEnvironment(EnvironmentEntity environment);
  Future<void> deleteEnvironment(String id);
  Future<void> selectEnvironment(String? id);
}
