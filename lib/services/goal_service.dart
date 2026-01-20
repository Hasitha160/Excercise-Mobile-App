import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add goal
  Future<String> addGoal(GoalModel goal) async {
    try {
      final docRef = await _firestore
          .collection('goals')
          .add(goal.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add goal: ${e.toString()}';
    }
  }

  // Update goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection('goals')
          .doc(goal.id)
          .update(goal.toFirestore());
    } catch (e) {
      throw 'Failed to update goal: ${e.toString()}';
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      throw 'Failed to delete goal: ${e.toString()}';
    }
  }

  // Get goals for user
  Stream<List<GoalModel>> getGoalsForUser(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final goals = snapshot.docs
              .map((doc) => GoalModel.fromFirestore(doc))
              .toList();
          // Sort in memory instead of using orderBy (avoids index requirement)
          goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return goals;
        });
  }

  // Get active goals
  Stream<List<GoalModel>> getActiveGoals(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalModel.fromFirestore(doc))
            .toList());
  }

  // Get completed goals
  Stream<List<GoalModel>> getCompletedGoals(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalModel.fromFirestore(doc))
            .toList());
  }

  // Update goal progress
  Future<void> updateGoalProgress(String goalId, double newValue) async {
    try {
      final goalDoc = await _firestore.collection('goals').doc(goalId).get();
      final goal = GoalModel.fromFirestore(goalDoc);

      final isCompleted = newValue >= goal.targetValue;

      await _firestore.collection('goals').doc(goalId).update({
        'currentValue': newValue,
        'isCompleted': isCompleted,
      });
    } catch (e) {
      throw 'Failed to update goal progress: ${e.toString()}';
    }
  }

  // Mark goal as completed
  Future<void> markGoalCompleted(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).update({
        'isCompleted': true,
      });
    } catch (e) {
      throw 'Failed to mark goal as completed: ${e.toString()}';
    }
  }
}
