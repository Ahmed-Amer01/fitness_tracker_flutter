import 'package:flutter/material.dart';
import '../models/health_metric_model.dart';
import '../services/health_metric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthMetricProvider extends ChangeNotifier {
  final HealthMetricService _service = HealthMetricService();
  List<HealthMetric> _metrics = [];
  bool _loading = false;
  String? _token;

  List<HealthMetric> get metrics => _metrics;
  bool get loading => _loading;

  HealthMetricProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) await fetchMetrics();
  }

  Future<void> fetchMetrics() async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      _metrics = await _service.fetchUserMetrics(_token!);
    } catch (e) {
      print('Error fetching metrics: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveMetric(HealthMetric metric) async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      metric.bmi = metric.height > 0
          ? metric.weight / ((metric.height / 100) * (metric.height / 100))
          : 0;
      if (metric.id != null) {
        await _service.updateMetric(_token!, metric.id!, metric);
      } else {
        await _service.createMetric(_token!, metric);
      }
      await fetchMetrics();
    } catch (e) {
      print('Error saving metric: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteMetric(String id) async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      await _service.deleteMetric(_token!, id);
      await fetchMetrics();
    } catch (e) {
      print('Error deleting metric: $e');
    }
    _loading = false;
    notifyListeners();
  }
}