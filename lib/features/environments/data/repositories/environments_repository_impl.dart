import '../../domain/entities/environment_entity.dart';
import '../../domain/repositories/environments_repository.dart';
import '../datasources/environments_local_datasource.dart';
import '../models/environment_model.dart';

class EnvironmentsRepositoryImpl implements EnvironmentsRepository {
  final EnvironmentsLocalDataSource localDataSource;

  EnvironmentsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<EnvironmentEntity>> getEnvironments() async {
    final models = await localDataSource.getEnvironments();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveEnvironment(EnvironmentEntity environment) async {
    final model = EnvironmentModel.fromEntity(environment);
    await localDataSource.saveEnvironment(model);
  }

  @override
  Future<void> deleteEnvironment(String id) async {
    await localDataSource.deleteEnvironment(id);
  }

  @override
  Future<void> selectEnvironment(String? id) async {
    await localDataSource.selectEnvironment(id);
  }
}
