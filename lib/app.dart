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
import 'features/taskroom/screens/create_task_screen.dart';
import 'features/taskroom/screens/personal_task_screen.dart';
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
        taskProvider.checkDailyReset();
        taskProvider.scheduleMidnightCleanup();
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
        },
      ),
    );
  }
}