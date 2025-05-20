import 'package:flutter/material.dart';

enum TaskType { daily, deadline }
enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final bool isCompleted;
  final TaskType type;
  final TaskPriority? priority;
  final int streak; // For daily tasks
  final DateTime? lastCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    required this.type,
    this.priority,
    this.streak = 0,
    this.lastCompleted,
  });

  // Dummy data untuk testing
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isCompleted,
    TaskType? type,
    TaskPriority? priority,
    int? streak,
    DateTime? lastCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
    );
  }

  // Dummy data dengan waktu
  static List<TaskModel> dummyTasks = [
    TaskModel(
      id: '1',
      title: 'Complete UI Design',
      description: 'Finish the home screen design',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      isCompleted: false,
      type: TaskType.deadline,
      priority: TaskPriority.high,
    ),
    TaskModel(
      id: '2',
      title: 'Morning Exercise',
      description: 'Complete 30 min workout',
      dueTime: TimeOfDay(hour: 6, minute: 30), // Tambahkan waktu
      isCompleted: true,
      type: TaskType.daily,
      streak: 3,
      lastCompleted: DateTime.now().subtract(Duration(days: 1)), // Kemarin
    ),
    TaskModel(
      id: '3',
      title: 'Reading Session',
      description: 'Read for 20 minutes',
      dueTime: TimeOfDay(hour: 21, minute: 0), // Waktu malam
      isCompleted: false,
      type: TaskType.daily,
      streak: 5,
      lastCompleted: DateTime.now().subtract(Duration(days: 1)), // Kemarin
    ),
  ];
}