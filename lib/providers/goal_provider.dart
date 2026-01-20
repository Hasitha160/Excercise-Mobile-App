import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalService _goalService = GoalService();
  
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<GoalModel>>? _goalsSubscription;

  List<GoalModel> get goals => _goals;
  List<GoalModel> get activeGoals => 
      _goals.where((goal) => !goal.isCompleted).toList();
  List<GoalModel> get completedGoals => 
      _goals.where((goal) => goal.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadGoals(String userId) {
    // Cancel existing subscription if any
    _goalsSubscription?.cancel();
    
    // Create new subscription
    _goalsSubscription = _goalService.getGoalsForUser(userId).listen(
      (goals) {
        _goals = goals;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }
  
  @override
  void dispose() {
    _goalsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> addGoal(GoalModel goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.addGoal(goal);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoal(GoalModel goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.updateGoal(goal);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.deleteGoal(goalId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoalProgress(String goalId, double newValue) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.updateGoalProgress(goalId, newValue);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markGoalCompleted(String goalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalService.markGoalCompleted(goalId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
