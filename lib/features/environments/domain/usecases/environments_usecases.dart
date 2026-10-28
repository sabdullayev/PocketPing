import '../entities/environment_entity.dart';
import '../repositories/environments_repository.dart';

class GetEnvironmentsUseCase {
  final EnvironmentsRepository repository;
  GetEnvironmentsUseCase(this.repository);

  Future<List<EnvironmentEntity>> call() => repository.getEnvironments();
}

class SaveEnvironmentUseCase {
  final EnvironmentsRepository repository;
  SaveEnvironmentUseCase(this.repository);

  Future<void> call(EnvironmentEntity environment) => repository.saveEnvironment(environment);
}

class DeleteEnvironmentUseCase {
  final EnvironmentsRepository repository;
  DeleteEnvironmentUseCase(this.repository);

  Future<void> call(String id) => repository.deleteEnvironment(id);
}

class SelectEnvironmentUseCase {
  final EnvironmentsRepository repository;
  SelectEnvironmentUseCase(this.repository);

  Future<void> call(String? id) => repository.selectEnvironment(id);
}
