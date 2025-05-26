import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../data/models/task_model.dart';
import '../providers/home_provider.dart';
import '../../taskroom/providers/task_provider.dart';
import 'package:intl/intl.dart';

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({Key? key}) : super(key: key);

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  @override
  void initState() {
    super.initState();
    // Pastikan task provider terset ke home provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.setTaskProvider(taskProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, TaskProvider>(
      builder: (context, homeProvider, taskProvider, child) {
        // Dapatkan data dari provider
        final todayDeadlines = homeProvider.todayDeadlines;
        final uncompletedDailyTasks = homeProvider.uncompletedDailyTasks;
        final completedTasksThisWeek = homeProvider.tasksCompletedThisWeek;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_active, color: Colors.red),
                SizedBox(width: 8),
                Text('Important for you', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            
            // ReminderBot Alert - Tampilkan deadline hari ini
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🤖 ReminderBot', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    todayDeadlines.isEmpty
                        ? 'You have no deadlines today. Enjoy your day!'
                        : 'You have ${todayDeadlines.length} deadline${todayDeadlines.length > 1 ? 's' : ''} today. Stay focused!',
                    style: AppTextStyles.bodyMedium
                  ),
                  
                  // Tampilkan maksimal 2 deadline hari ini jika ada
                  if (todayDeadlines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...todayDeadlines.take(2).map((task) => _buildDeadlineItem(task)),
                    
                    // Tampilkan tombol "more" jika ada lebih dari 2 deadline
                    if (todayDeadlines.length > 2) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showReminderBotPopup(context, todayDeadlines),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'more',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Project Alert - Tetap jadi dummy sementara
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From Project Room: UAS Mobile App', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 8),
                  const Text('@King Our deadline is today, don\'t forget!', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Reply action
                      },
                      child: const Text('Reply'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // What's Going On Section
            Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text('What\'s Going On', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            
            // Daily tasks remaining
            if (uncompletedDailyTasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining today: ${uncompletedDailyTasks.length} daily task${uncompletedDailyTasks.length > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        // Tombol More untuk What's Going On
                        GestureDetector(
                          onTap: () => _showWhatsGoingOnPopup(context, uncompletedDailyTasks),
                          child: Row(
                            children: const [
                              Text(
                                'more',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Activity Log
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '✅ You completed $completedTasksThisWeek task${completedTasksThisWeek != 1 ? 's' : ''} this week',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Widget untuk menampilkan deadline item
  Widget _buildDeadlineItem(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: _getPriorityColor(task.priority),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getPriorityColor(task.priority),
              ),
            ),
          ),
          if (task.dueTime != null)
            Text(
              task.dueTime!.format(context),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan daily task item dengan streak
  Widget _buildDailyTaskItem(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔥 ${task.streak}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.streak > 0)
                  Text(
                    ' day${task.streak > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper untuk mendapatkan warna berdasarkan prioritas
  Color _getPriorityColor(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
  
  // Fungsi untuk menampilkan popup ReminderBot
  void _showReminderBotPopup(BuildContext context, List<TaskModel> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🤖 ReminderBot', style: AppTextStyles.heading3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You have ${tasks.length} deadline${tasks.length > 1 ? 's' : ''} today',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                // Scrollable deadline tasks
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tasks.map((task) => _buildDeadlineItem(task)).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/personal-task');
                    },
                    child: const Text('Go to Your Personal Task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Fungsi untuk menampilkan popup What's Going On
  void _showWhatsGoingOnPopup(BuildContext context, List<TaskModel> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("What's Going On", style: AppTextStyles.heading3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining today: ${tasks.length} daily task${tasks.length > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                // Scrollable daily tasks
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tasks.map((task) => _buildDailyTaskItem(task)).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/personal-task');
                    },
                    child: const Text('Go to Your Personal Task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}