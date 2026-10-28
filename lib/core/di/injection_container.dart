import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/dio_client.dart';
import '../../features/collections/data/datasources/collections_local_datasource.dart';
import '../../features/collections/data/repositories/collections_repository_impl.dart';
import '../../features/collections/domain/repositories/collections_repository.dart';
import '../../features/collections/domain/usecases/collections_usecases.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/environments/data/datasources/environments_local_datasource.dart';
import '../../features/environments/data/repositories/environments_repository_impl.dart';
import '../../features/environments/domain/repositories/environments_repository.dart';
import '../../features/environments/domain/usecases/environments_usecases.dart';
import '../../features/environments/domain/usecases/substitute_env_variables_usecase.dart';
import '../../features/environments/presentation/bloc/environments_bloc.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/history_usecases.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/monitor/data/datasources/monitor_local_datasource.dart';
import '../../features/monitor/data/repositories/monitor_repository_impl.dart';
import '../../features/monitor/domain/repositories/monitor_repository.dart';
import '../../features/monitor/domain/usecases/monitor_usecases.dart';
import '../../features/monitor/presentation/bloc/monitor_bloc.dart';
import '../../features/request_builder/data/repositories/request_repository_impl.dart';
import '../../features/request_builder/domain/repositories/request_repository.dart';
import '../../features/request_builder/domain/usecases/execute_request_usecase.dart';
import '../../features/request_builder/presentation/bloc/request_builder_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({String? hivePath}) async {
  // 1. Hive Storage Initialization
  if (hivePath != null) {
    Hive.init(hivePath);
  } else {
    await Hive.initFlutter();
  }

  // 2. Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // 3. Request Builder Feature
  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<ExecuteRequestUseCase>(
    () => ExecuteRequestUseCase(sl()),
  );

  // 4. History Feature
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(sl()),
  );
  sl.registerLazySingleton<SaveHistoryItemUseCase>(
    () => SaveHistoryItemUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteHistoryItemUseCase>(
    () => DeleteHistoryItemUseCase(sl()),
  );
  sl.registerLazySingleton<ClearHistoryUseCase>(
    () => ClearHistoryUseCase(sl()),
  );
  sl.registerLazySingleton<HistoryBloc>(
    () => HistoryBloc(
      getHistoryUseCase: sl(),
      saveHistoryItemUseCase: sl(),
      deleteHistoryItemUseCase: sl(),
      clearHistoryUseCase: sl(),
    ),
  );

  // 5. Collections Feature
  sl.registerLazySingleton<CollectionsLocalDataSource>(
    () => CollectionsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CollectionsRepository>(
    () => CollectionsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetCollectionsUseCase>(
    () => GetCollectionsUseCase(sl()),
  );
  sl.registerLazySingleton<SaveCollectionUseCase>(
    () => SaveCollectionUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteCollectionUseCase>(
    () => DeleteCollectionUseCase(sl()),
  );
  sl.registerLazySingleton<SaveRequestToCollectionUseCase>(
    () => SaveRequestToCollectionUseCase(sl()),
  );
  sl.registerLazySingleton<RemoveRequestFromCollectionUseCase>(
    () => RemoveRequestFromCollectionUseCase(sl()),
  );
  sl.registerFactory<CollectionsBloc>(
    () => CollectionsBloc(
      getCollectionsUseCase: sl(),
      saveCollectionUseCase: sl(),
      deleteCollectionUseCase: sl(),
      saveRequestToCollectionUseCase: sl(),
      removeRequestFromCollectionUseCase: sl(),
    ),
  );

  // 6. Environments Feature
  sl.registerLazySingleton<EnvironmentsLocalDataSource>(
    () => EnvironmentsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<EnvironmentsRepository>(
    () => EnvironmentsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetEnvironmentsUseCase>(
    () => GetEnvironmentsUseCase(sl()),
  );
  sl.registerLazySingleton<SaveEnvironmentUseCase>(
    () => SaveEnvironmentUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteEnvironmentUseCase>(
    () => DeleteEnvironmentUseCase(sl()),
  );
  sl.registerLazySingleton<SelectEnvironmentUseCase>(
    () => SelectEnvironmentUseCase(sl()),
  );
  sl.registerLazySingleton<SubstituteEnvVariablesUseCase>(
    () => SubstituteEnvVariablesUseCase(),
  );
  sl.registerLazySingleton<EnvironmentsBloc>(
    () => EnvironmentsBloc(
      getEnvironmentsUseCase: sl(),
      saveEnvironmentUseCase: sl(),
      deleteEnvironmentUseCase: sl(),
      selectEnvironmentUseCase: sl(),
    ),
  );

  // 7. Health Check Monitor Feature
  sl.registerLazySingleton<MonitorLocalDataSource>(
    () => MonitorLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<MonitorRepository>(
    () => MonitorRepositoryImpl(
      localDataSource: sl(),
      dioClient: sl(),
    ),
  );
  sl.registerLazySingleton<GetMonitorTargetsUseCase>(
    () => GetMonitorTargetsUseCase(sl()),
  );
  sl.registerLazySingleton<SaveMonitorTargetUseCase>(
    () => SaveMonitorTargetUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteMonitorTargetUseCase>(
    () => DeleteMonitorTargetUseCase(sl()),
  );
  sl.registerLazySingleton<PingTargetUseCase>(
    () => PingTargetUseCase(sl()),
  );
  sl.registerFactory<MonitorBloc>(
    () => MonitorBloc(
      getMonitorTargetsUseCase: sl(),
      saveMonitorTargetUseCase: sl(),
      deleteMonitorTargetUseCase: sl(),
      pingTargetUseCase: sl(),
    ),
  );

  // 8. Request Builder Bloc
  sl.registerFactory<RequestBuilderBloc>(
    () => RequestBuilderBloc(
      executeRequestUseCase: sl(),
      saveHistoryItemUseCase: sl(),
      substituteEnvVariablesUseCase: sl(),
      environmentsBloc: sl(),
      historyBloc: sl(),
    ),
  );
}
