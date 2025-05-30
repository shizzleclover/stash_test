import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/stash.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class StashProvider extends ChangeNotifier {
  List<Stash> _stashes = [];
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  final _uuid = const Uuid();

  // Getters
  List<Stash> get stashes => List.unmodifiable(_stashes);
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasStashes => _stashes.isNotEmpty;

  // Computed properties
  double get totalSaved => _stashes.fold(0, (sum, stash) => sum + stash.currentAmount);
  double get totalTarget => _stashes.fold(0, (sum, stash) => sum + stash.targetAmount);
  double get overallProgress => totalTarget > 0 ? (totalSaved / totalTarget * 100).clamp(0, 100) : 0;
  int get completedStashes => _stashes.where((stash) => stash.isCompleted).length;

  Future<void> loadStashes() async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      _stashes = StorageService.getAllStashes();
      _stashes.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to load stashes';
      _setLoadingState(LoadingState.error);
    }
  }

  Future<void> createStash({
    required String name,
    required double targetAmount,
    required String category,
    required DateTime startDate,
    double initialAmount = 0,
  }) async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      final stash = Stash(
        id: _uuid.v4(),
        name: name,
        currentAmount: initialAmount,
        targetAmount: targetAmount,
        category: category,
        createdDate: startDate,
      );

      if (initialAmount > 0) {
        stash.addContribution(initialAmount);
      }

      await StorageService.saveStash(stash);
      _stashes.insert(0, stash);
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to create stash';
      _setLoadingState(LoadingState.error);
    }
  }

  Future<void> addContribution(String stashId, double amount) async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      final stashIndex = _stashes.indexWhere((s) => s.id == stashId);
      if (stashIndex == -1) {
        throw Exception('Stash not found');
      }

      final stash = _stashes[stashIndex];
      stash.addContribution(amount);
      
      await StorageService.updateStash(stash);
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to add contribution';
      _setLoadingState(LoadingState.error);
    }
  }

  Future<void> updateStash(Stash updatedStash) async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      final stashIndex = _stashes.indexWhere((s) => s.id == updatedStash.id);
      if (stashIndex == -1) {
        throw Exception('Stash not found');
      }

      _stashes[stashIndex] = updatedStash;
      await StorageService.updateStash(updatedStash);
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to update stash';
      _setLoadingState(LoadingState.error);
    }
  }

  Future<void> deleteStash(String stashId) async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    try {
      await StorageService.deleteStash(stashId);
      _stashes.removeWhere((s) => s.id == stashId);
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to delete stash';
      _setLoadingState(LoadingState.error);
    }
  }

  Stash? getStashById(String id) {
    try {
      return _stashes.firstWhere((stash) => stash.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Stash> getStashesByCategory(String category) {
    return _stashes.where((stash) => stash.category == category).toList();
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