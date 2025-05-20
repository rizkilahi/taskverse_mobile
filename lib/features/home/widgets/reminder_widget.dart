import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';

class ReminderWidget extends StatelessWidget {
  const ReminderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        
        // ReminderBot Alert
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('🤖 ReminderBot', style: AppTextStyles.bodyLarge),
              SizedBox(height: 8),
              Text('You have 2 deadlines today. Stay focused!', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Project Alert
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
        
        // Project Update
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('From Project Room: UAS Mobile App\n@King assigned you "Redesign UI" Thread View', style: AppTextStyles.bodyMedium),
        ),
        const SizedBox(height: 16),
        
        // Activity Log
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('✅ You completed 3 tasks this week', style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}