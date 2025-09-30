import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_model.dart';

class NutritionService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<Nutrition>> getNutritions({
    String? token,
    String? name,
    int? minCalories,
    int? maxCalories,
    String? sortBy,
    String direction = 'asc',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/nutrition').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (minCalories != null) 'min_calories': minCalories.toString(),
          if (maxCalories != null) 'max_calories': maxCalories.toString(),
          if (sortBy != null) 'sort': sortBy,
          'direction': direction,
        },
      );

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Nutrition.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch nutrition items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Nutrition> getNutritionById(String id, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/nutrition/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Nutrition.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch nutrition item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Nutrition> createNutrition(CreateNutritionDto nutrition,
      {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/nutrition'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(nutrition.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Nutrition.fromJson(data);
      } else {
        throw Exception(
            'Failed to create nutrition item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Nutrition> updateNutrition(String id, UpdateNutritionDto nutrition,
      {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/nutrition/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(nutrition.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Nutrition.fromJson(data);
      } else {
        throw Exception(
            'Failed to update nutrition item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteNutrition(String id, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/nutrition/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete nutrition item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> restoreNutrition(String id, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/nutrition/$id/restore'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to restore nutrition item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<Nutrition>> getNutritionsByCategory(NutritionCategory category,
      {String? token}) async {
    try {
      final allNutritions = await getNutritions(token: token);
      return allNutritions.where((n) => n.category == category).toList();
    } catch (e) {
      throw Exception('Failed to fetch nutrition by category: ${e.toString()}');
    }
  }
}
