import 'package:flutter/material.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../shared/navigation/bottom_nav_bar.dart';
import '../widgets/personal_task_card.dart';
import '../widgets/project_task_card.dart';
import '../widgets/thread_area_widget.dart';
import '../../../core/utils/ui_utils.dart';

class TaskRoomScreen extends StatefulWidget {
  const TaskRoomScreen({Key? key}) : super(key: key);

  @override
  State<TaskRoomScreen> createState() => _TaskRoomScreenState();
}

class _TaskRoomScreenState extends State<TaskRoomScreen> {
  int _currentIndex = 1; // TaskRoom selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '🚀 Let\'s get things rolling!',
                style: AppTextStyles.heading1,
              ),
              const Text(
                'This is where your tasks turn into victories.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Your Personal Task Card
              const PersonalTaskCard(),
              const SizedBox(height: 16),
              
              // Project Tasks Card
              const ProjectTaskCard(),
              const SizedBox(height: 16),
              
              // Thread Area
              const ThreadAreaWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Already on TaskRoom
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/thread');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
      floatingActionButton: UiUtils.pulseAnimation(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-task');
          },
        child: const Icon(Icons.add),
        ),
      ),
    );
  }
}