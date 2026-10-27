import '../../domain/entities/history_item_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/history_item_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<HistoryItemEntity>> getHistory() async {
    final models = await localDataSource.getHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveHistoryItem(HistoryItemEntity item) async {
    final model = HistoryItemModel.fromEntity(item);
    await localDataSource.saveHistoryItem(model);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    await localDataSource.deleteHistoryItem(id);
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}
