import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  
  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<WorkoutModel>>? _workoutsSubscription;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadWorkouts(String userId) {
    // Cancel existing subscription if any
    _workoutsSubscription?.cancel();
    
    // Create new subscription
    _workoutsSubscription = _workoutService.getWorkoutsForUser(userId).listen(
      (workouts) {
        _workouts = workouts;
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
    _workoutsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> addWorkout(WorkoutModel workout) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutService.addWorkout(workout);
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

  Future<bool> updateWorkout(WorkoutModel workout) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutService.updateWorkout(workout);
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

  Future<bool> deleteWorkout(String workoutId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutService.deleteWorkout(workoutId);
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

  List<WorkoutModel> getWorkoutsForDate(DateTime date) {
    return _workouts.where((workout) {
      return workout.date.year == date.year &&
          workout.date.month == date.month &&
          workout.date.day == date.day;
    }).toList();
  }

  double getTotalCaloriesForDate(DateTime date) {
    final workoutsForDate = getWorkoutsForDate(date);
    return workoutsForDate.fold(
      0.0,
      (sum, workout) => sum + workout.caloriesBurned,
    );
  }

  int getTotalDurationForDate(DateTime date) {
    final workoutsForDate = getWorkoutsForDate(date);
    return workoutsForDate.fold(
      0,
      (sum, workout) => sum + workout.durationMinutes,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
