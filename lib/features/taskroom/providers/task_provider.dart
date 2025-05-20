// Modifikasi file: lib/features/taskroom/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = TaskModel.dummyTasks;
  
  List<TaskModel> get tasks => _tasks;
  
  List<TaskModel> get dailyTasks => 
      _tasks.where((task) => task.type == TaskType.daily).toList();
      
  List<TaskModel> get deadlineTasks => 
      _tasks.where((task) => task.type == TaskType.deadline).toList();
  
  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }
  
  // Update untuk mengelola streak
  void updateDailyTask(String id, {bool? isCompleted}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      
      // Hanya proses jika daily task
      if (task.type == TaskType.daily) {
        int newStreak = task.streak;
        DateTime? newLastCompleted;
        
        if (isCompleted == true) {
          // Jika task dinyatakan selesai
          newLastCompleted = now;
          
          // Cek apakah ini adalah hari yang berbeda dari terakhir completed
          if (task.lastCompleted == null) {
            // Task pertama kali diselesaikan
            newStreak = 1;
          } else {
            final lastCompletedDate = DateTime(
              task.lastCompleted!.year,
              task.lastCompleted!.month,
              task.lastCompleted!.day,
            );
            
            // Cek apakah hari ini atau kemarin
            if (today.difference(lastCompletedDate).inDays == 1) {
              // Kemarin, maka streak berlanjut
              newStreak = task.streak + 1;
            } else if (today.difference(lastCompletedDate).inDays > 1) {
              // Lebih dari 1 hari, streak reset
              newStreak = 1;
            } else if (today.difference(lastCompletedDate).inDays == 0) {
              // Hari yang sama, streak tidak berubah
              newStreak = task.streak;
            }
          }
        } else if (isCompleted == false && task.isCompleted == true) {
          // Jika task dibatalkan setelah selesai
          // Reset streak jika dibatalkan hari ini 
          if (task.lastCompleted != null) {
            final lastCompletedDate = DateTime(
              task.lastCompleted!.year,
              task.lastCompleted!.month,
              task.lastCompleted!.day,
            );
            
            if (today.difference(lastCompletedDate).inDays == 0) {
              // Jika dibatalkan di hari yang sama
              newStreak = task.streak > 0 ? task.streak - 1 : 0;
              // Jika streak > 1, kembalikan ke hari kemarin
              newLastCompleted = newStreak > 0 
                  ? today.subtract(Duration(days: 1)) 
                  : null;
            }
          }
        }
        
        // Update task
        _tasks[index] = task.copyWith(
          isCompleted: isCompleted ?? task.isCompleted,
          streak: newStreak,
          lastCompleted: newLastCompleted,
        );
      } else {
        // Untuk non-daily task, update seperti biasa
        _tasks[index] = task.copyWith(
          isCompleted: isCompleted ?? task.isCompleted,
        );
      }
      
      notifyListeners();
    }
  }
  
  // Metode untuk sebelumnya updateTask
  void updateTask(String id, {bool? isCompleted}) {
    // Panggil metode baru untuk daily task
    updateDailyTask(id, isCompleted: isCompleted);
  }
  
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
  
  // Metode baru untuk memeriksa dan mereset daily tasks setiap hari
  void checkDailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Reset status selesai untuk daily tasks
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.type == TaskType.daily && task.isCompleted) {
        // Cek apakah task diselesaikan kemarin
        if (task.lastCompleted != null) {
          final lastCompletedDate = DateTime(
            task.lastCompleted!.year,
            task.lastCompleted!.month,
            task.lastCompleted!.day,
          );
          
          // Jika bukan hari ini, reset completed status
          if (today.compareTo(lastCompletedDate) > 0) {
            _tasks[i] = task.copyWith(isCompleted: false);
          }
        }
      }
    }
    
    notifyListeners();
  }

   void cleanCompletedDeadlineTasks() {
    // Buat salinan list dengan hanya task yang:
    // - Bukan deadline task yang sudah selesai
    // - Atau semua daily tasks (tetap dipertahankan)
    _tasks = _tasks.where((task) => 
      task.type == TaskType.daily || 
      (task.type == TaskType.deadline && !task.isCompleted)
    ).toList();
    
    notifyListeners();
  }
  
  // Method untuk melakukan pengecekan dan pembersihan otomatis
  void checkAndCleanTasks() {
    // 1. Reset daily tasks (method yang sudah ada)
    checkDailyReset();
    
    // 2. Bersihkan deadline tasks yang sudah selesai
    cleanCompletedDeadlineTasks();
  }
  
  // Method untuk menjadwalkan pembersihan otomatis jam 00:00
  void scheduleMidnightCleanup() {
    final now = DateTime.now();
    
    // Hitung waktu sampai tengah malam berikutnya
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = midnight.difference(now);
    
    // Jadwalkan pembersihan
    Future.delayed(timeUntilMidnight, () {
      // Bersihkan task
      checkAndCleanTasks();
      
      // Jadwalkan lagi untuk tengah malam berikutnya (rekursif)
      scheduleMidnightCleanup();
    });
  }

}