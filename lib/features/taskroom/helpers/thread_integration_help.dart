// File: lib/features/taskroom/helpers/thread_integration_helper.dart

import '../../../data/models/project_model.dart';
import '../../../data/models/thread_model.dart';
import '../../../data/models/thread_member_model.dart';
import '../../../data/models/message_model.dart'; // Import MessageType dari sini
import '../../../data/models/user_model.dart';
import '../../thread/providers/thread_provider.dart';

class ThreadIntegrationHelper {
  static const String PROJECT_THREAD_PREFIX = '#';
  
  /// Create main project thread when project is created
  static Future<ThreadModel?> createProjectThread({
    required ProjectModel project,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Convert project members to thread members
      final threadMembers = project.members.map((projectMember) {
        return ThreadMemberModel(
          user: projectMember.user,
          role: _convertProjectRoleToMemberRole(projectMember.role),
          status: MemberStatus.online, // Default status
          lastActive: DateTime.now(),
        );
      }).toList();

      final mainThreadName = formatProjectThreadName(project.name);
      
      // Create main project thread using ThreadProvider's existing method
      await threadProvider.createHQThread(
        name: mainThreadName,
        description: project.description ?? 'Main project discussion thread',
        members: threadMembers,
        customSubThreads: ['general', 'tasks', 'updates'], // Default sub-threads
      );

      // Find the created thread (ThreadProvider akan membuat dengan ID yang unik)
      final createdThreads = threadProvider.projectThreads
          .where((thread) => thread.name == mainThreadName)
          .toList();
      
      if (createdThreads.isNotEmpty) {
        final mainThread = createdThreads.first;
        
        // Update thread dengan project ID (jika ThreadProvider mendukung)
        // Untuk sementara, return thread yang sudah dibuat
        return mainThread;
      }

      return null;
    } catch (e) {
      print('Error creating project thread: $e');
      return null;
    }
  }

  /// Add member to all project threads when added to project
  static Future<void> addMemberToProjectThreads({
    required String projectId,
    required ProjectMember newMember,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Get all threads related to this project
      final projectThreads = getProjectThreadsByProjectId(projectId, threadProvider);
      
      final threadMember = ThreadMemberModel(
        user: newMember.user,
        role: _convertProjectRoleToMemberRole(newMember.role),
        status: MemberStatus.online,
        lastActive: DateTime.now(),
      );

      // Add member to all project threads
      // Note: ThreadProvider belum punya method addMemberToThread,
      // jadi ini placeholder untuk future implementation
      for (final thread in projectThreads) {
        // TODO: Implement addMemberToThread di ThreadProvider
        print('Would add ${newMember.user.name} to thread ${thread.name}');
      }
    } catch (e) {
      print('Error adding member to project threads: $e');
    }
  }

  /// Remove member from all project threads when removed from project
  static Future<void> removeMemberFromProjectThreads({
    required String projectId,
    required String userId,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Get all threads related to this project
      final projectThreads = getProjectThreadsByProjectId(projectId, threadProvider);

      // Remove member from all project threads
      for (final thread in projectThreads) {
        // TODO: Implement removeMemberFromThread di ThreadProvider
        print('Would remove user $userId from thread ${thread.name}');
      }
    } catch (e) {
      print('Error removing member from project threads: $e');
    }
  }

  /// Update member role in all project threads when role changes
  static Future<void> updateMemberRoleInProjectThreads({
    required String projectId,
    required String userId,
    required ProjectRole newRole,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Get all threads related to this project
      final projectThreads = getProjectThreadsByProjectId(projectId, threadProvider);
      
      final newMemberRole = _convertProjectRoleToMemberRole(newRole);

      // Update member role in all project threads
      for (final thread in projectThreads) {
        await threadProvider.updateMemberRole(
          threadId: thread.id,
          userId: userId,
          role: newMemberRole,
        );
      }
    } catch (e) {
      print('Error updating member role in project threads: $e');
    }
  }

  /// Delete all project threads when project is deleted
  static Future<void> deleteProjectThreads({
    required String projectId,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Get all threads related to this project
      final projectThreads = getProjectThreadsByProjectId(projectId, threadProvider);

      // Delete all project threads
      // Note: ThreadProvider belum punya method deleteThread,
      // jadi ini placeholder untuk future implementation
      for (final thread in projectThreads) {
        // TODO: Implement deleteThread di ThreadProvider
        print('Would delete thread ${thread.name} (${thread.id})');
      }
    } catch (e) {
      print('Error deleting project threads: $e');
    }
  }

  /// Convert ProjectRole to MemberRole (existing enum)
  static MemberRole _convertProjectRoleToMemberRole(ProjectRole projectRole) {
    switch (projectRole) {
      case ProjectRole.admin:
        return MemberRole.admin;
      case ProjectRole.member:
        return MemberRole.member;
      case ProjectRole.viewer:
        return MemberRole.member; // Viewer jadi member biasa di thread
    }
  }

  /// Send system message to project thread
  static Future<void> sendProjectSystemMessage({
    required String projectId,
    required String message,
    required ThreadProvider threadProvider,
  }) async {
    try {
      // Get main project thread
      final mainThread = getMainProjectThread(projectId, threadProvider);
      
      if (mainThread != null) {
        // Switch to that thread and send message
        threadProvider.selectThread(mainThread.id);
        await threadProvider.sendMessage(
          content: message,
          type: MessageType.system,
        );
      }
    } catch (e) {
      print('Error sending project system message: $e');
    }
  }

  /// Get project thread URL for navigation
  static String getProjectThreadRoute(String projectId) {
    return '/thread?project=$projectId';
  }

  /// Get formatted thread name for project
  static String formatProjectThreadName(String projectName) {
    // Remove special characters and spaces, make lowercase
    final cleanName = projectName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    
    return '$PROJECT_THREAD_PREFIX$cleanName';
  }

  /// Check if user has permission to perform action in project thread
  static bool hasThreadPermission({
    required ProjectModel project,
    required String userId,
    required ThreadAction action,
  }) {
    try {
      final userRole = project.getUserRole(userId);
      if (userRole == null) return false;

      switch (action) {
        case ThreadAction.read:
          return true; // All project members can read
        case ThreadAction.write:
          return userRole != ProjectRole.viewer; // Members and admins can write
        case ThreadAction.manageMembers:
          return userRole == ProjectRole.admin; // Only admins can manage
        case ThreadAction.deleteThread:
          return userRole == ProjectRole.admin; // Only admins can delete
      }
    } catch (e) {
      return false; // User not found in project
    }
  }

  // Helper methods using existing ThreadProvider functionality

  /// Get threads related to project ID using existing ThreadProvider methods
  static List<ThreadModel> getProjectThreadsByProjectId(String projectId, ThreadProvider threadProvider) {
    // Since ThreadProvider doesn't have getThreadsByProjectId yet,
    // we'll filter project threads by matching project ID or thread name pattern
    return threadProvider.projectThreads.where((thread) {
      // Check if thread has projectId field (when available)
      if (thread.projectId == projectId) return true;
      
      // For now, we can't reliably identify project threads by projectId
      // This should be improved when projectId field is properly used
      return false;
    }).toList();
  }

  /// Get main project thread using existing ThreadProvider methods
  static ThreadModel? getMainProjectThread(String projectId, ThreadProvider threadProvider) {
    final projectThreads = getProjectThreadsByProjectId(projectId, threadProvider);
    
    if (projectThreads.isEmpty) return null;
    
    // Return thread that doesn't have parent (main thread)
    try {
      return projectThreads.firstWhere(
        (thread) => thread.parentThreadId == null,
      );
    } catch (e) {
      // If no main thread found, return first available
      return projectThreads.first;
    }
  }

  /// Convert project member to thread member
  static ThreadMemberModel convertProjectMemberToThreadMember(ProjectMember projectMember) {
    return ThreadMemberModel(
      user: projectMember.user,
      role: _convertProjectRoleToMemberRole(projectMember.role),
      status: MemberStatus.online, // Default status
      lastActive: DateTime.now(),
    );
  }

  /// Send welcome message when project is created
  static Future<void> sendWelcomeMessage({
    required ProjectModel project,
    required ThreadProvider threadProvider,
  }) async {
    await sendProjectSystemMessage(
      projectId: project.id,
      message: '🎉 Welcome to ${project.name}! Project has been created successfully.',
      threadProvider: threadProvider,
    );
  }

  /// Send member joined message
  static Future<void> sendMemberJoinedMessage({
    required String projectId,
    required ProjectMember member,
    required ThreadProvider threadProvider,
  }) async {
    await sendProjectSystemMessage(
      projectId: projectId,
      message: '👋 ${member.user.name} joined the project as ${member.role.toString().split('.').last}',
      threadProvider: threadProvider,
    );
  }

  /// Send member left message
  static Future<void> sendMemberLeftMessage({
    required String projectId,
    required String userName,
    required ThreadProvider threadProvider,
  }) async {
    await sendProjectSystemMessage(
      projectId: projectId,
      message: '👋 $userName left the project',
      threadProvider: threadProvider,
    );
  }
}

enum ThreadAction {
  read,
  write,
  manageMembers,
  deleteThread,
}