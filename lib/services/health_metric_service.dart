import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_metric_model.dart';

class HealthMetricService {
  static const String baseUrl = 'http://10.0.2.2:8080/health-metrics';

  Future<List<HealthMetric>> fetchUserMetrics(String token) async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => HealthMetric.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch metrics: ${response.statusCode} ${response.body}');
      }
    } catch(e){
      print('Error fetching metrics: $e');
      rethrow;
    }
  }

  Future<HealthMetric> createMetric(String token, HealthMetric metric) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(metric.toJson()),
      );

      if (response.statusCode == 200) {
        return HealthMetric.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to create metric: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating metric: $e');
      rethrow;
    }
  }

  Future<HealthMetric> updateMetric(String token, String id, HealthMetric metric) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(metric.toJson()),
      );

      if (response.statusCode == 200) {
        return HealthMetric.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update metric: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating metric: $e');
      rethrow;
    }
  }

  Future<void> deleteMetric(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete metric: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting metric: $e');
      rethrow;
    }
  } 
}