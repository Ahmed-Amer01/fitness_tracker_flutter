import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<Exercise>> getExercises({
    String? token,
    String? name,
    String? category,
    String? sortBy,
    String direction = 'asc',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/exercises').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (category != null) 'category': category,
          if (sortBy != null) 'sort_by': sortBy,
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
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Exercise> getExerciseById(String id, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/exercises/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Failed to fetch exercise: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Exercise> createExercise(CreateExerciseDto exercise,
      {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/exercises'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(exercise.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Failed to create exercise: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Exercise> updateExercise(String id, UpdateExerciseDto exercise,
      {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/exercises/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(exercise.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Exercise.fromJson(data);
      } else {
        throw Exception('Failed to update exercise: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteExercise(String id, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/exercises/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete exercise: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> restoreExercise(String id, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/exercises/$id/restore'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to restore exercise: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category,
      {String? token}) async {
    return getExercises(
      token: token,
      category: category.name.toUpperCase(),
    );
  }
}
