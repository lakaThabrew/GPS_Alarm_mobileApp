import 'package:flutter/foundation.dart';
import '../models/search_history.dart';
import '../models/destination.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class HistoryProvider with ChangeNotifier {
  List<SearchHistory> _history = [];
  bool _isLoading = true;

  List<SearchHistory> get history => _history;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _history = await StorageService.getHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistory(Destination dest) async {
    final item = SearchHistory(
      id: const Uuid().v4(),
      destination: dest,
      timestamp: DateTime.now(),
    );
    _history.insert(0, item);
    await StorageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await StorageService.clearHistory();
    notifyListeners();
  }
}
