import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class ExerciseProvider with ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService();

  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ExerciseCategory? _categoryFilter;

  // Getters
  List<Exercise> get exercises => _exercises;
  List<Exercise> get filteredExercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ExerciseCategory? get categoryFilter => _categoryFilter;

  // Initialize and fetch exercises
  Future<void> fetchExercises({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      _exercises = await _exerciseService.getExercises(token: token);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get exercise by ID
  Future<Exercise?> getExerciseById(String id, {String? token}) async {
    try {
      return await _exerciseService.getExerciseById(id, token: token);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Create exercise
  Future<bool> createExercise(CreateExerciseDto exercise,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final newExercise =
          await _exerciseService.createExercise(exercise, token: token);
      _exercises.add(newExercise);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update exercise
  Future<bool> updateExercise(String id, UpdateExerciseDto exercise,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedExercise =
          await _exerciseService.updateExercise(id, exercise, token: token);
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = updatedExercise;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete exercise
  Future<bool> deleteExercise(String id, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      await _exerciseService.deleteExercise(id, token: token);
      _exercises.removeWhere((e) => e.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search exercises
  void searchExercises(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(ExerciseCategory? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredExercises = _exercises.where((exercise) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!exercise.name.toLowerCase().contains(query) &&
            (exercise.description?.toLowerCase().contains(query) != true)) {
          return false;
        }
      }

      // Category filter
      if (_categoryFilter != null && exercise.category != _categoryFilter!) {
        return false;
      }

      return true;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get exercises by category
  List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return _filteredExercises.where((e) => e.category == category).toList();
  }

  // Get exercises by tracking mode
  List<Exercise> getExercisesByTrackingMode(TrackingMode mode) {
    return _filteredExercises.where((e) => e.trackingMode == mode).toList();
  }

  // Get exercises that require weights
  List<Exercise> getWeightExercises() {
    return _filteredExercises.where((e) => e.hasWeights).toList();
  }

  // Get bodyweight exercises
  List<Exercise> getBodyweightExercises() {
    return _filteredExercises.where((e) => !e.hasWeights).toList();
  }

  // Get all categories with counts
  Map<ExerciseCategory, int> getCategoryCounts() {
    Map<ExerciseCategory, int> counts = {};
    for (final exercise in _exercises) {
      counts[exercise.category] = (counts[exercise.category] ?? 0) + 1;
    }
    return counts;
  }
}
