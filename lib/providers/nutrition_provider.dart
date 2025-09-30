import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';
import '../services/nutrition_service.dart';

class NutritionProvider with ChangeNotifier {
  final NutritionService _nutritionService = NutritionService();

  List<Nutrition> _nutritions = [];
  List<Nutrition> _filteredNutritions = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  NutritionCategory? _categoryFilter;
  int? _minCalories;
  int? _maxCalories;

  // Getters
  List<Nutrition> get nutritions => _nutritions;
  List<Nutrition> get filteredNutritions => _filteredNutritions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  NutritionCategory? get categoryFilter => _categoryFilter;
  int? get minCalories => _minCalories;
  int? get maxCalories => _maxCalories;

  // Initialize and fetch nutritions
  Future<void> fetchNutritions({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      _nutritions = await _nutritionService.getNutritions(
        token: token,
        minCalories: _minCalories,
        maxCalories: _maxCalories,
      );
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get nutrition by ID
  Future<Nutrition?> getNutritionById(String id, {String? token}) async {
    try {
      return await _nutritionService.getNutritionById(id, token: token);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Create nutrition
  Future<bool> createNutrition(CreateNutritionDto nutrition,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final newNutrition =
          await _nutritionService.createNutrition(nutrition, token: token);
      _nutritions.add(newNutrition);
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

  // Update nutrition
  Future<bool> updateNutrition(String id, UpdateNutritionDto nutrition,
      {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedNutrition =
          await _nutritionService.updateNutrition(id, nutrition, token: token);
      final index = _nutritions.indexWhere((n) => n.id == id);
      if (index != -1) {
        _nutritions[index] = updatedNutrition;
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

  // Delete nutrition
  Future<bool> deleteNutrition(String id, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      await _nutritionService.deleteNutrition(id, token: token);
      _nutritions.removeWhere((n) => n.id == id);
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

  // Search nutritions
  void searchNutritions(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(NutritionCategory? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  // Filter by calories range
  void filterByCalories({int? min, int? max}) {
    _minCalories = min;
    _maxCalories = max;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredNutritions = _nutritions.where((nutrition) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!nutrition.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_categoryFilter != null && nutrition.category != _categoryFilter!) {
        return false;
      }

      // Calories filter
      if (_minCalories != null &&
          (nutrition.caloriesPer100g == null ||
              nutrition.caloriesPer100g! < _minCalories!)) {
        return false;
      }
      if (_maxCalories != null &&
          (nutrition.caloriesPer100g == null ||
              nutrition.caloriesPer100g! > _maxCalories!)) {
        return false;
      }

      return true;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _minCalories = null;
    _maxCalories = null;
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

  // Get nutritions by category
  List<Nutrition> getNutritionsByCategory(NutritionCategory category) {
    return _filteredNutritions.where((n) => n.category == category).toList();
  }

  // Get high protein foods
  List<Nutrition> getHighProteinFoods({double minProtein = 20.0}) {
    return _filteredNutritions
        .where(
            (n) => n.proteinPer100g != null && n.proteinPer100g! >= minProtein)
        .toList();
  }

  // Get low calorie foods
  List<Nutrition> getLowCalorieFoods({double maxCalories = 100.0}) {
    return _filteredNutritions
        .where((n) =>
            n.caloriesPer100g != null && n.caloriesPer100g! <= maxCalories)
        .toList();
  }

  // Get all categories with counts
  Map<NutritionCategory, int> getCategoryCounts() {
    Map<NutritionCategory, int> counts = {};
    for (final nutrition in _nutritions) {
      counts[nutrition.category] = (counts[nutrition.category] ?? 0) + 1;
    }
    return counts;
  }

  // Calculate nutrition summary for a list of items
  Map<String, double> calculateNutritionSummary(
      List<Nutrition> items, List<double> quantities) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    double totalFiber = 0;
    double totalSugar = 0;

    for (int i = 0; i < items.length && i < quantities.length; i++) {
      final nutrition = items[i];
      final quantity = quantities[i];
      final multiplier = quantity / 100; // Convert to per 100g basis

      totalCalories += (nutrition.caloriesPer100g ?? 0) * multiplier;
      totalProtein += (nutrition.proteinPer100g ?? 0) * multiplier;
      totalCarbs += (nutrition.carbsPer100g ?? 0) * multiplier;
      totalFats += (nutrition.fatsPer100g ?? 0) * multiplier;
      totalFiber += (nutrition.fiberPer100g ?? 0) * multiplier;
      totalSugar += (nutrition.sugarPer100g ?? 0) * multiplier;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
      'fiber': totalFiber,
      'sugar': totalSugar,
    };
  }
}
