class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final int taskCount;
  final int threadCount;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.taskCount,
    required this.threadCount,
    required this.createdAt,
  });

  // Dummy data untuk testing
  static List<ProjectModel> dummyProjects = [
    ProjectModel(
      id: '1',
      name: 'UAS Mobile App',
      description: 'Final project for Mobile App Development class',
      taskCount: 5,
      threadCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ProjectModel(
      id: '2',
      name: 'UAS Mobile App',
      description: 'Another project',
      taskCount: 3,
      threadCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}