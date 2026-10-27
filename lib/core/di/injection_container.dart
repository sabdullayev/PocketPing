import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/request_builder/data/repositories/request_repository_impl.dart';
import '../../features/request_builder/domain/repositories/request_repository.dart';
import '../../features/request_builder/domain/usecases/execute_request_usecase.dart';
import '../../features/request_builder/presentation/bloc/request_builder_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Repositories
  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(dioClient: sl()),
  );

  // UseCases
  sl.registerLazySingleton<ExecuteRequestUseCase>(
    () => ExecuteRequestUseCase(sl()),
  );

  // BLoCs
  sl.registerFactory<RequestBuilderBloc>(
    () => RequestBuilderBloc(executeRequestUseCase: sl()),
  );
}
