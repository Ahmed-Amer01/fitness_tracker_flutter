import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _service = GoalService();
  List<Goal> _goals = [];
  bool _loading = false;
  String? _token;

  List<Goal> get goals => _goals;
  bool get loading => _loading;

  GoalProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await fetchGoals();
    } else {
      Fluttertoast.showToast(
        msg: 'No authentication token found. Please log in.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> fetchGoals() async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      _goals = await _service.fetchUserGoals(_token!);
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to fetch goals: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveGoal(Goal goal) async {
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
      if (goal.id != null) {
        await _service.updateGoal(_token!, goal.id!, goal);
        Fluttertoast.showToast(
          msg: 'Goal updated successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        await _service.createGoal(_token!, goal);
        Fluttertoast.showToast(
          msg: 'Goal added successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
      await fetchGoals();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save goal: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
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
      await _service.deleteGoal(_token!, id);
      await fetchGoals();
      Fluttertoast.showToast(
        msg: 'Goal deleted successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete goal: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    _loading = false;
    notifyListeners();
  }

  Map<String, int> getStatusCounts() {
    return _goals.fold<Map<String, int>>(
      {'NOT_STARTED': 0, 'IN_PROGRESS': 0, 'ACHIEVED': 0, 'ABANDONED': 0},
      (map, goal) {
        final statusKey = goal.status.serverValue;
        map[statusKey] = (map[statusKey] ?? 0) + 1;
        return map;
      },
    );
  }
}