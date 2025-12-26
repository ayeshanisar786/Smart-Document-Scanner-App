import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initializeAuth() async {
    // TODO: Implement Firebase Auth initialization
    // For now, simulate initialization
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    // TODO: Implement sign out
    _isAuthenticated = false;
    notifyListeners();
  }
}
