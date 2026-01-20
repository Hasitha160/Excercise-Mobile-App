import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String? id;
  final String userId;
  final String exerciseName;
  final String category; // Cardio, Strength, Flexibility, etc.
  final int durationMinutes;
  final int? sets;
  final int? reps;
  final double? weight; // in kg
  final double caloriesBurned;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.category,
    required this.durationMinutes,
    this.sets,
    this.reps,
    this.weight,
    required this.caloriesBurned,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      category: data['category'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      sets: data['sets'],
      reps: data['reps'],
      weight: data['weight']?.toDouble(),
      caloriesBurned: (data['caloriesBurned'] ?? 0).toDouble(),
      notes: data['notes'],
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'category': category,
      'durationMinutes': durationMinutes,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? exerciseName,
    String? category,
    int? durationMinutes,
    int? sets,
    int? reps,
    double? weight,
    double? caloriesBurned,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
