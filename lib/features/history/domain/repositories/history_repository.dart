import '../entities/history_item_entity.dart';

abstract class HistoryRepository {
  Future<List<HistoryItemEntity>> getHistory();
  Future<void> saveHistoryItem(HistoryItemEntity item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}
