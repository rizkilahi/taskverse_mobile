import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/thread_model.dart';
import '../../thread/providers/thread_provider.dart';

enum ProjectLoadingState { idle, loading, success, error }

class CreateProjectRequest {
  final String name;
  final String? description;
  final List<String> memberIds;
  final Map<String, ProjectRole> memberRoles;

  CreateProjectRequest({
    required this.name,
    this.description,
    required this.memberIds,
    required this.memberRoles,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'member_ids': memberIds,
      'member_roles': memberRoles.map(
        (userId, role) => MapEntry(userId, role.toString().split('.').last),
      ),
    };
  }
}

class ProjectProvider with ChangeNotifier {
  List<ProjectModel> _projects = ProjectModel.dummyProjects;
  ProjectLoadingState _loadingState = ProjectLoadingState.idle;
  String? _errorMessage;
  ThreadProvider? _threadProvider;

  // Getters
  List<ProjectModel> get projects => _projects;
  ProjectLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == ProjectLoadingState.loading;

  // Setter untuk ThreadProvider (dependency injection)
  void setThreadProvider(ThreadProvider threadProvider) {
    _threadProvider = threadProvider;
  }

  // Get projects where current user is member
  List<ProjectModel> get userProjects {
    final currentUserId = UserModel.currentUser.id;
    return _projects.where((project) => 
      project.isUserMember(currentUserId)
    ).toList();
  }

  // Get projects created by current user
  List<ProjectModel> get createdProjects {
    final currentUserId = UserModel.currentUser.id;
    return _projects.where((project) => 
      project.creatorId == currentUserId
    ).toList();
  }

  // Backend integration ready methods
  
  /// Fetch projects from backend
  Future<void> fetchProjects() async {
    _setLoadingState(ProjectLoadingState.loading);
    
    try {
      // TODO: Implement actual API call
      // final response = await _apiService.get('/projects');
      // final projectsData = response.data as List;
      // _projects = projectsData.map((json) => ProjectModel.fromJson(json)).toList();
      
      // Simulation: delay untuk mimic network request
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For now, use dummy data
      _projects = ProjectModel.dummyProjects;
      
      _setLoadingState(ProjectLoadingState.success);
    } catch (e) {
      _setLoadingState(ProjectLoadingState.error);
      _errorMessage = 'Failed to fetch projects: $e';
    }
  }

  /// Create new project room
  Future<ProjectModel?> createProject(CreateProjectRequest request) async {
    _setLoadingState(ProjectLoadingState.loading);
    
    try {
      // TODO: Implement actual API call
      // final response = await _apiService.post('/projects', data: request.toJson());
      // final newProject = ProjectModel.fromJson(response.data);
      
      // Simulation: Create project locally
      final newProjectId = DateTime.now().millisecondsSinceEpoch.toString();
      final currentUser = UserModel.currentUser;
      
      // Create project members list
      final members = <ProjectMember>[];
      
      // Add creator as admin
      members.add(ProjectMember(
        userId: currentUser.id,
        user: currentUser,
        role: ProjectRole.admin,
        joinedAt: DateTime.now(),
      ));
      
      // Add other members
      for (final memberId in request.memberIds) {
        if (memberId != currentUser.id) {
          // TODO: Fetch actual user data from backend
          final user = _getDummyUser(memberId);
          final role = request.memberRoles[memberId] ?? ProjectRole.member;
          
          members.add(ProjectMember(
            userId: memberId,
            user: user,
            role: role,
            joinedAt: DateTime.now(),
          ));
        }
      }
      
      final newProject = ProjectModel(
        id: newProjectId,
        name: request.name,
        description: request.description,
        creatorId: currentUser.id,
        creator: currentUser,
        members: members,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        threadId: 'project-$newProjectId', // Will be created by thread system
      );
      
      // Add to local list
      _projects.add(newProject);
      
      // Auto-create project thread
      await _createProjectThread(newProject);
      
      _setLoadingState(ProjectLoadingState.success);
      _errorMessage = null;
      
      return newProject;
      
    } catch (e) {
      _setLoadingState(ProjectLoadingState.error);
      _errorMessage = 'Failed to create project: $e';
      return null;
    }
  }

  /// Add member to project
  Future<bool> addMemberToProject(String projectId, String userId, ProjectRole role) async {
    try {
      // TODO: Implement actual API call
      // await _apiService.post('/projects/$projectId/members', data: {
      //   'user_id': userId,
      //   'role': role.toString().split('.').last,
      // });
      
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final project = _projects[projectIndex];
        final user = _getDummyUser(userId); // TODO: Fetch from backend
        
        final newMember = ProjectMember(
          userId: userId,
          user: user,
          role: role,
          joinedAt: DateTime.now(),
        );
        
        final updatedMembers = List<ProjectMember>.from(project.members)
          ..add(newMember);
        
        _projects[projectIndex] = project.copyWith(
          members: updatedMembers,
          updatedAt: DateTime.now(),
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Failed to add member: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove member from project
  Future<bool> removeMemberFromProject(String projectId, String userId) async {
    try {
      // TODO: Implement actual API call
      // await _apiService.delete('/projects/$projectId/members/$userId');
      
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final project = _projects[projectIndex];
        
        final updatedMembers = project.members
            .where((member) => member.userId != userId)
            .toList();
        
        _projects[projectIndex] = project.copyWith(
          members: updatedMembers,
          updatedAt: DateTime.now(),
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Failed to remove member: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update project details
  Future<bool> updateProject(String projectId, {
    String? name,
    String? description,
    ProjectStatus? status,
  }) async {
    try {
      // TODO: Implement actual API call
      // await _apiService.put('/projects/$projectId', data: {
      //   'name': name,
      //   'description': description,
      //   'status': status?.toString().split('.').last,
      // });
      
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final project = _projects[projectIndex];
        
        _projects[projectIndex] = project.copyWith(
          name: name ?? project.name,
          description: description ?? project.description,
          status: status ?? project.status,
          updatedAt: DateTime.now(),
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      // TODO: Implement actual API call
      // await _apiService.delete('/projects/$projectId');
      
      _projects.removeWhere((project) => project.id == projectId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get project by ID
  ProjectModel? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  
  void _setLoadingState(ProjectLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Auto-create thread when project is created
  Future<void> _createProjectThread(ProjectModel project) async {
    if (_threadProvider != null) {
      try {
        // Create main project thread
        final mainThread = ThreadModel(
          id: project.threadId!,
          name: '#${project.name}',
          type: ThreadType.project,
          projectId: project.id,
          members: project.members.map((member) => 
            // TODO: Convert ProjectMember to ThreadMember
            // This is placeholder - actual implementation depends on ThreadMemberModel
            throw UnimplementedError('Convert ProjectMember to ThreadMember')
          ).toList(),
          createdAt: project.createdAt,
          updatedAt: project.updatedAt,
          description: project.description,
        );
        
        // TODO: Call thread provider to create thread
        // await _threadProvider!.createThread(mainThread);
        
      } catch (e) {
        debugPrint('Failed to create project thread: $e');
        // Don't fail project creation if thread creation fails
      }
    }
  }

  /// Get dummy user data (TODO: Replace with actual backend call)
  UserModel _getDummyUser(String userId) {
    // TODO: Implement actual user fetching from backend
    // For now, return dummy users
    switch (userId) {
      case '2':
        return UserModel(id: '2', name: 'King', email: 'king@example.com');
      case '3':
        return UserModel(id: '3', name: 'Alice', email: 'alice@example.com');
      case '4':
        return UserModel(id: '4', name: 'Bob', email: 'bob@example.com');
      default:
        return UserModel(id: userId, name: 'User $userId', email: 'user$userId@example.com');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh projects
  Future<void> refreshProjects() async {
    await fetchProjects();
  }
}