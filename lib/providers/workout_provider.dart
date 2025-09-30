import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  List<Workout> _workouts = [];
  List<Workout> _filteredWorkouts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool? _sharedFilter;

  // Getters
  List<Workout> get workouts => _workouts;
  List<Workout> get filteredWorkouts => _filteredWorkouts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool? get sharedFilter => _sharedFilter;

  // Initialize and fetch workouts
  Future<void> fetchWorkouts({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      _workouts = await _workoutService.getWorkouts(token: token);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkoutById(String id, {String? token}) async {
    try {
      return await _workoutService.getWorkoutById(id, token: token);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Create workout
  Future<bool> createWorkout(CreateWorkoutDto workout, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final newWorkout =
          await _workoutService.createWorkout(workout, token: token);
      _workouts.add(newWorkout);
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

  // Update workout
  Future<bool> updateWorkout(String id, UpdateWorkoutDto workout,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedWorkout =
          await _workoutService.updateWorkout(id, workout, token: token);
      final index = _workouts.indexWhere((w) => w.id == id);
      if (index != -1) {
        _workouts[index] = updatedWorkout;
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

  // Delete workout
  Future<bool> deleteWorkout(String id, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      await _workoutService.deleteWorkout(id, token: token);
      _workouts.removeWhere((w) => w.id == id);
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

  // Add exercises to workout
  Future<bool> addExercisesToWorkout(
      String workoutId, List<Map<String, dynamic>> exercises,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedWorkout = await _workoutService
          .addExercisesToWorkout(workoutId, exercises, token: token);
      final index = _workouts.indexWhere((w) => w.id == workoutId);
      if (index != -1) {
        _workouts[index] = updatedWorkout;
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

  // Search workouts
  void searchWorkouts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by shared status
  void filterByShared(bool? shared) {
    _sharedFilter = shared;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredWorkouts = _workouts.where((workout) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!workout.name.toLowerCase().contains(query) &&
            (workout.description?.toLowerCase().contains(query) != true)) {
          return false;
        }
      }

      // Shared filter
      if (_sharedFilter != null && workout.isShared != _sharedFilter!) {
        return false;
      }

      return true;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _sharedFilter = null;
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

  // Get workouts by exercise count
  List<Workout> getWorkoutsByExerciseCount(int minExercises) {
    return _filteredWorkouts
        .where((w) => w.workoutExercises.length >= minExercises)
        .toList();
  }

  // Get shared workouts
  List<Workout> getSharedWorkouts() {
    return _filteredWorkouts.where((w) => w.isShared).toList();
  }

  // Get my workouts
  List<Workout> getMyWorkouts(String userId) {
    return _filteredWorkouts.where((w) => w.createdById == userId).toList();
  }
}
