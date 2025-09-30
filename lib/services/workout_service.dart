import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';

class WorkoutService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<Workout>> getWorkouts({
    String? token,
    String? name,
    bool? shared,
    String? sortBy,
    String direction = 'asc',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/workouts').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (shared != null) 'shared': shared.toString(),
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
        return data.map((json) => Workout.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch workouts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Workout> getWorkoutById(String id, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/workouts/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Workout.fromJson(data);
      } else {
        throw Exception('Failed to fetch workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Workout> createWorkout(CreateWorkoutDto workout,
      {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/workouts'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(workout.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Workout.fromJson(data);
      } else {
        throw Exception('Failed to create workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Workout> updateWorkout(String id, UpdateWorkoutDto workout,
      {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/workouts/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(workout.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Workout.fromJson(data);
      } else {
        throw Exception('Failed to update workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteWorkout(String id, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/workouts/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Workout> addExercisesToWorkout(
      String workoutId, List<Map<String, dynamic>> exercises,
      {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/workouts/$workoutId/exercises'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(exercises),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Workout.fromJson(data);
      } else {
        throw Exception(
            'Failed to add exercises to workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> restoreWorkout(String id, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/workouts/$id/restore'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to restore workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
