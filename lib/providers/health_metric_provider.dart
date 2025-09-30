import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_metric_model.dart';
import '../services/health_metric_service.dart';

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
    if (_token != null) {
      await fetchMetrics();
    } else {
      Fluttertoast.showToast(
        msg: 'No authentication token found. Please log in.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> fetchMetrics() async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      _metrics = await _service.fetchUserMetrics(_token!);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to fetch metrics: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveMetric(HealthMetric metric) async {
    if (_token == null) {
      Fluttertoast.showToast(
        msg: 'No authentication token. Please log in.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      metric.bmi = metric.height > 0
          ? metric.weight / ((metric.height / 100) * (metric.height / 100))
          : 0;
      if (metric.id != null) {
        await _service.updateMetric(_token!, metric.id!, metric);
        Fluttertoast.showToast(
          msg: 'Metric updated successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        await _service.createMetric(_token!, metric);
        Fluttertoast.showToast(
          msg: 'Metric added successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
      await fetchMetrics();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save metric: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteMetric(String id) async {
    if (_token == null) {
      Fluttertoast.showToast(
        msg: 'No authentication token. Please log in.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      await _service.deleteMetric(_token!, id);
      await fetchMetrics();
      Fluttertoast.showToast(
        msg: 'Metric deleted successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete metric: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }
}