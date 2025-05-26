// File: lib/app.dart (Updated with Project Integration)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/taskroom/screens/taskroom_screen.dart';
import 'features/thread/screens/thread_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'providers/navigation_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/taskroom/providers/task_provider.dart';
import 'features/taskroom/providers/project_provider.dart'; // NEW
import 'features/thread/providers/thread_provider.dart';
import 'features/taskroom/screens/create_task_screen.dart';
import 'features/taskroom/screens/personal_task_screen.dart';
import 'features/taskroom/screens/create_project_screen.dart'; // NEW
import 'config/app_scroll_behavior.dart';

class TaskVerseApp extends StatefulWidget {
  const TaskVerseApp({Key? key}) : super(key: key);

  @override
  State<TaskVerseApp> createState() => _TaskVerseAppState();
}

class _TaskVerseAppState extends State<TaskVerseApp> {
  @override
  void initState() {
    super.initState();
    // Jadwalkan cek daily reset untuk daily tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Perlu runlater karena provider belum tersedia di initState
      Future.microtask(() {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false); // NEW
        final threadProvider = Provider.of<ThreadProvider>(context, listen: false);
        
        // Initialize task provider
        taskProvider.checkDailyReset();
        taskProvider.scheduleMidnightCleanup();
        
        // Initialize project provider  // NEW
        projectProvider.setThreadProvider(threadProvider); // NEW
        projectProvider.fetchProjects(); // NEW
        
        // Initialize thread provider
        threadProvider.fetchThreads();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()), // NEW
        ChangeNotifierProvider(create: (_) => ThreadProvider()),
      ],
      child: MaterialApp(
        title: 'TaskVerse',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/taskroom': (context) => const TaskRoomScreen(),
          '/thread': (context) => const ThreadScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/personal-task': (context) => const PersonalTaskScreen(),
          '/create-task': (context) => const CreateTaskScreen(),
          '/create-project': (context) => const CreateProjectScreen(), // NEW
        },
      ),
    );
  }
}

// File: lib/main.dart (Updated with Project Provider)

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/taskroom/providers/task_provider.dart';
import 'features/taskroom/providers/project_provider.dart'; // NEW
import 'features/thread/providers/thread_provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()), // NEW
        ChangeNotifierProvider(create: (_) => ThreadProvider()),
      ],
      child: const TaskVerseApp(),
    ),
  );
}
*/

// File: lib/features/taskroom/screens/taskroom_screen.dart (Updated FAB)

/*
PERUBAHAN PADA FAB DI TASKROOM_SCREEN.dart:

floatingActionButton: UiUtils.pulseAnimation(
  child: FloatingActionButton(
    onPressed: () {
      // Show dialog to choose between Personal Task or Project Task
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create New'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: AppColors.secondary),
                ),
                title: const Text('Create Personal Task'),
                subtitle: const Text('Private task for you only'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/create-task');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.group, color: AppColors.primary),
                ),
                title: const Text('Create Project Task'),
                subtitle: const Text('Collaborative workspace with team'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/create-project');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    },
    child: const Icon(Icons.add),
  ),
),
*/