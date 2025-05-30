import '../models/user.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  static Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simple validation - just check if fields are not empty
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return AuthResult.failure('Email and password cannot be empty');
    }

    if (!_isValidEmail(email)) {
      return AuthResult.failure('Please enter a valid email address');
    }

    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters');
    }

    // Mock successful login
    _currentUser = User(
      id: 'user_123',
      email: email,
      name: _extractNameFromEmail(email),
    );

    // Save user to storage
    await StorageService.saveUser(_currentUser!.toJson());

    return AuthResult.success(_currentUser!);
  }

  static Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearUser();
  }

  static Future<void> loadUserFromStorage() async {
    final userData = StorageService.getCurrentUser();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username.split('.').map((part) => 
      part.isNotEmpty ? '${part[0].toUpperCase()}${part.substring(1)}' : ''
    ).join(' ');
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) => AuthResult._(
    isSuccess: true,
    user: user,
  );

  factory AuthResult.failure(String errorMessage) => AuthResult._(
    isSuccess: false,
    errorMessage: errorMessage,
  );
} 