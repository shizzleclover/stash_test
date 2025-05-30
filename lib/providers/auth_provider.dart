import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthState _authState = AuthState.unknown;
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  AuthState get authState => _authState;
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _loadingState == LoadingState.loading;

  Future<void> initializeAuth() async {
    try {
      await AuthService.loadUserFromStorage();
      _user = AuthService.currentUser;
      _authState = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = 'Failed to load user data';
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      final result = await AuthService.login(email, password);
      
      if (result.isSuccess) {
        _user = result.user;
        _authState = AuthState.authenticated;
        _setLoadingState(LoadingState.success);
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _setLoadingState(LoadingState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoadingState(LoadingState.error);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
      _user = null;
      _authState = AuthState.unauthenticated;
      _setLoadingState(LoadingState.idle);
      _clearError();
    } catch (e) {
      _errorMessage = 'Failed to logout';
    }
  }

  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();
} 