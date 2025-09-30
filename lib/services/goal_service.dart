import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/goal_model.dart';

class GoalService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/goals';

  Future<List<Goal>> fetchUserGoals(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Goal.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch goals: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching goals: $e');
      rethrow;
    }
  }

  Future<Goal> createGoal(String token, Goal goal) async {
    try {
      // print('Sending JSON: ${jsonEncode(goal.toJson())}'); // Debug JSON payload
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 201) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to create goal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating goal: $e');
      rethrow;
    }
  }

  Future<Goal> updateGoal(String token, String id, Goal goal) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 200) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update goal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete goal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }
}