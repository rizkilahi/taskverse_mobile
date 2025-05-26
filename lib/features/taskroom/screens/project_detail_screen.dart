// File: lib/features/taskroom/screens/project_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/user_model.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  
  const ProjectDetailScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProjectModel? project;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get project data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      setState(() {
        project = projectProvider.getProjectById(widget.projectId);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: const Center(
          child: Text('Project not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with project info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                project!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 40), // Space for app bar
                      if (project!.description != null) ...[
                        Text(
                          project!.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Project stats
                      Row(
                        children: [
                          _buildStatItem(Icons.people, '${project!.members.length}', 'Members'),
                          const SizedBox(width: 20),
                          _buildStatItem(Icons.task, '${project!.taskCount}', 'Tasks'),
                          const SizedBox(width: 20),
                          _buildStatItem(Icons.chat, '${project!.threadCount}', 'Threads'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Tasks'),
                Tab(text: 'Members'),
              ],
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTasksTab(),
                _buildMembersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildProjectFAB(),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project description
          if (project!.description != null) ...[
            const Text('Description', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(project!.description!),
            ),
            const SizedBox(height: 24),
          ],
          
          // Quick actions
          const Text('Quick Actions', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.chat,
                  title: 'Open Thread',
                  subtitle: 'Join project discussion',
                  onTap: () {
                    // TODO: Navigate to project thread
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening project thread...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_task,
                  title: 'Add Task',
                  subtitle: 'Create new project task',
                  onTap: () {
                    // TODO: Navigate to create project task
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create project task - Coming Soon')),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          const Text('Recent Activity', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        // Tasks header with add button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Project Tasks', style: AppTextStyles.heading3),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Create project task
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create project task - Coming Soon')),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Tasks list
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: project!.taskCount > 0
                ? _buildProjectTasksList()
                : _buildEmptyTasksState(),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Members header
          Row(
            children: [
              Text('Members (${project!.members.length})', style: AppTextStyles.heading3),
              const Spacer(),
              if (project!.isUserAdmin(UserModel.currentUser.id))
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddMemberDialog();
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Members list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: project!.members.length,
            itemBuilder: (context, index) {
              final member = project!.members[index];
              return _buildMemberCard(member);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    // Dummy activity data - TODO: Implement real activity tracking
    final activities = [
      {'user': 'King', 'action': 'added a new task "UI Design"', 'time': '2h ago'},
      {'user': 'Alice', 'action': 'completed task "Research Phase"', 'time': '4h ago'},
      {'user': 'You', 'action': 'updated project description', 'time': '1d ago'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              activity['user']![0],
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: activity['user'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${activity['action']}'),
              ],
            ),
          ),
          subtitle: Text(activity['time']!),
        );
      },
    );
  }

  Widget _buildProjectTasksList() {
    // TODO: Implement actual project tasks list
    return Center(
      child: Text(
        'Project tasks list\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No project tasks yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project task to get started',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ProjectMember member) {
    final isCurrentUser = member.userId == UserModel.currentUser.id;
    final canManageMembers = project!.isUserAdmin(UserModel.currentUser.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            member.user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(member.user.name),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(member.user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(member.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleText(member.role),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getRoleColor(member.role),
                ),
              ),
            ),
            if (canManageMembers && !isCurrentUser)
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change Role'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove Member'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeMember(member);
                  } else if (value == 'change_role') {
                    _showChangeRoleDialog(member);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFAB() {
    return FloatingActionButton(
      onPressed: () {
        _showProjectActionsDialog();
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.more_horiz, color: Colors.white),
    );
  }

  void _showProjectActionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Open Project Thread'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to thread
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_task),
              title: const Text('Add Project Task'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add project task
              },
            ),
            if (project!.isUserAdmin(UserModel.currentUser.id)) ...[
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Project Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Project settings
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    // TODO: Implement add member dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add member functionality - Coming Soon')),
    );
  }

  void _showChangeRoleDialog(ProjectMember member) {
    // TODO: Implement change role dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change role for ${member.user.name} - Coming Soon')),
    );
  }

  void _removeMember(ProjectMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.user.name} from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
              projectProvider.removeMemberFromProject(project!.id, member.userId);
              setState(() {
                project = projectProvider.getProjectById(widget.projectId);
              });
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(ProjectRole role) {
    switch (role) {
      case ProjectRole.admin:
        return Colors.red;
      case ProjectRole.member:
        return Colors.blue;
      case ProjectRole.viewer:
        return Colors.green;
    }
  }

  String _getRoleText(ProjectRole role) {
    switch (role) {
      case ProjectRole.admin:
        return 'Admin';
      case ProjectRole.member:
        return 'Member';
      case ProjectRole.viewer:
        return 'Viewer';
    }
  }
}