import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String type; // weekly_workouts, weight_loss, duration, calories, etc.
  final double targetValue;
  final double currentValue;
  final String unit; // workouts, kg, minutes, calories
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime createdAt;

  GoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    required this.startDate,
    required this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      targetValue: (data['targetValue'] ?? 0).toDouble(),
      currentValue: (data['currentValue'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
