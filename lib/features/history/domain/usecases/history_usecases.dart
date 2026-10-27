import '../entities/history_item_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;
  GetHistoryUseCase(this.repository);

  Future<List<HistoryItemEntity>> call() => repository.getHistory();
}

class SaveHistoryItemUseCase {
  final HistoryRepository repository;
  SaveHistoryItemUseCase(this.repository);

  Future<void> call(HistoryItemEntity item) => repository.saveHistoryItem(item);
}

class DeleteHistoryItemUseCase {
  final HistoryRepository repository;
  DeleteHistoryItemUseCase(this.repository);

  Future<void> call(String id) => repository.deleteHistoryItem(id);
}

class ClearHistoryUseCase {
  final HistoryRepository repository;
  ClearHistoryUseCase(this.repository);

  Future<void> call() => repository.clearHistory();
}
