import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';

class ThreadAreaWidget extends StatelessWidget {
  const ThreadAreaWidget({Key? key}) : super(key: key);

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
              children: const [
                Icon(Icons.chat, color: Colors.green),
                SizedBox(width: 8),
                Text('Thread Area', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            
            // Thread item
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('# Thread : Project Room - Mobile App UAS', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.person, size: 16),
                      SizedBox(width: 4),
                      Text('@King assigned you "Redesign UI"', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('2h ago', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Another thread item
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('# Thread : Project Room - Mobile App UAS', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.person, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text('@King assigned you "Redesign UI"', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('5h ago', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // View all threads
                },
                child: const Text('View all', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}