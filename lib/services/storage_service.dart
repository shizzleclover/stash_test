import 'package:hive_flutter/hive_flutter.dart';
import '../models/stash.dart';

class StorageService {
  static const String _stashBoxName = 'stashes';
  static const String _userBoxName = 'user';
  
  static Box<Stash>? _stashBox;
  static Box? _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(StashAdapter());
    Hive.registerAdapter(ContributionAdapter());
    
    // Open boxes
    _stashBox = await Hive.openBox<Stash>(_stashBoxName);
    _userBox = await Hive.openBox(_userBoxName);
  }

  static Box<Stash> get stashBox {
    if (_stashBox == null || !_stashBox!.isOpen) {
      throw Exception('Stash box is not initialized');
    }
    return _stashBox!;
  }

  static Box get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('User box is not initialized');
    }
    return _userBox!;
  }

  // Stash operations
  static Future<void> saveStash(Stash stash) async {
    await stashBox.put(stash.id, stash);
  }

  static List<Stash> getAllStashes() {
    return stashBox.values.toList();
  }

  static Stash? getStash(String id) {
    return stashBox.get(id);
  }

  static Future<void> deleteStash(String id) async {
    await stashBox.delete(id);
  }

  static Future<void> updateStash(Stash stash) async {
    await stashBox.put(stash.id, stash);
  }

  // User operations
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await userBox.put('current_user', userData);
  }

  static Map<String, dynamic>? getCurrentUser() {
    return userBox.get('current_user');
  }

  static Future<void> clearUser() async {
    await userBox.delete('current_user');
  }

  static bool get isLoggedIn => getCurrentUser() != null;

  // Clear all data
  static Future<void> clearAllData() async {
    await stashBox.clear();
    await userBox.clear();
  }
} 