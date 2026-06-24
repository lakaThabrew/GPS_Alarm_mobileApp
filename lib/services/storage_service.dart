import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_history.dart';
import '../models/user.dart';

class StorageService {
  static const String _historyKey = 'search_history';
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // --- Search History ---
  static Future<List<SearchHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((item) => SearchHistory.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHistory(List<SearchHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  static Future<void> addHistoryItem(SearchHistory item) async {
    final history = await getHistory();
    history.insert(0, item);
    await saveHistory(history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // --- User Auth (Simulated) ---
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(usersJson);
      return decoded.map((item) => User.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  static Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  static Future<void> setCurrentUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    }
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }
}
