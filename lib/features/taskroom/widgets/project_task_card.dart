import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';

class ProjectTaskCard extends StatelessWidget {
  const ProjectTaskCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assume we have no projects for empty state
    final bool hasProjects = false;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.group, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Project Tasks', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            
            if (hasProjects)
              // Show project list
              const Text('Project list goes here')
            else
              // Show empty state
              SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('It\'s quiet here...', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Start a project now and invite your teammates to collaborate and get things done together.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Create new project
                      },
                      child: const Icon(Icons.add),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}