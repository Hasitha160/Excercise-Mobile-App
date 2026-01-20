import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add workout
  Future<String> addWorkout(WorkoutModel workout) async {
    try {
      final docRef = await _firestore
          .collection('workouts')
          .add(workout.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add workout: ${e.toString()}';
    }
  }

  // Update workout
  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      await _firestore
          .collection('workouts')
          .doc(workout.id)
          .update(workout.toFirestore());
    } catch (e) {
      throw 'Failed to update workout: ${e.toString()}';
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore.collection('workouts').doc(workoutId).delete();
    } catch (e) {
      throw 'Failed to delete workout: ${e.toString()}';
    }
  }

  // Get workouts for user
  Stream<List<WorkoutModel>> getWorkoutsForUser(String userId) {
    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final workouts = snapshot.docs
              .map((doc) => WorkoutModel.fromFirestore(doc))
              .toList();
          // Sort in memory instead of using orderBy (avoids index requirement)
          workouts.sort((a, b) => b.date.compareTo(a.date));
          return workouts;
        });
  }

  // Get workouts for specific date
  Stream<List<WorkoutModel>> getWorkoutsForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromFirestore(doc))
            .toList());
  }

  // Get workouts for date range
  Stream<List<WorkoutModel>> getWorkoutsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromFirestore(doc))
            .toList());
  }

  // Get total calories burned for a date range
  Future<double> getTotalCalories(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final workout = WorkoutModel.fromFirestore(doc);
      total += workout.caloriesBurned;
    }
    return total;
  }

  // Get total workout duration for a date range
  Future<int> getTotalDuration(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int total = 0;
    for (var doc in snapshot.docs) {
      final workout = WorkoutModel.fromFirestore(doc);
      total += workout.durationMinutes;
    }
    return total;
  }

  // Get workout count for date range
  Future<int> getWorkoutCount(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.length;
  }
}
