import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../core/utils/ui_utils.dart';

class ProjectListWidget extends StatelessWidget {
  const ProjectListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.folder, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Your Project List', style: AppTextStyles.heading3),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all projects
                  },
                  child: const Text('View All', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Project List with animations
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ProjectModel.dummyProjects.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final project = ProjectModel.dummyProjects[index];
                return UiUtils.fadeInCard(
                  index: index,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(project.name, style: AppTextStyles.bodyLarge),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.assignment, size: 16),
                        Text(' ${project.taskCount} Task'),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, size: 16),
                        Text(' ${project.threadCount} Thread'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to project details
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}