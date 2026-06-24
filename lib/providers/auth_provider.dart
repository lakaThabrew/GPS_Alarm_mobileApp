import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _currentUser = await StorageService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String passwordHash) async {
    final users = await StorageService.getUsers();
    try {
      final user = users.firstWhere(
        (u) => u.username == username && u.passwordHash == passwordHash,
      );
      _currentUser = user;
      await StorageService.setCurrentUser(user);
      notifyListeners();
      return true;
    } catch (e) {
      return false; // User not found
    }
  }

  Future<bool> register(String username, String fullName, String passwordHash) async {
    final users = await StorageService.getUsers();
    final exists = users.any((u) => u.username == username);
    if (exists) return false;

    final newUser = User(username: username, fullName: fullName, passwordHash: passwordHash);
    await StorageService.addUser(newUser);
    _currentUser = newUser;
    await StorageService.setCurrentUser(newUser);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await StorageService.setCurrentUser(null);
    notifyListeners();
  }
}
