import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/navigation/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3; // Profile selected
  
  @override
  Widget build(BuildContext context) {
    final user = UserModel.currentUser;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Profile avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // User name
              Text(
                user.name,
                style: AppTextStyles.heading1,
              ),
              Text(
                user.email,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Tasks', '12'),
                    _buildStatItem('Projects', '3'),
                    _buildStatItem('Completed', '8'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile sections
              _buildProfileSection(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  // Navigate to settings
                },
              ),
              _buildProfileSection(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () {
                  // Navigate to notifications
                },
              ),
              _buildProfileSection(
                icon: Icons.privacy_tip,
                title: 'Privacy',
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              _buildProfileSection(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  // Navigate to help
                },
              ),
              _buildProfileSection(
                icon: Icons.logout,
                title: 'Log Out',
                textColor: Colors.red,
                onTap: () {
                  // Log out action
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/taskroom');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/thread');
              break;
            case 3:
              // Already on Profile
              break;
          }
        },
      ),
    );
  }

  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildProfileSection({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.iconColor),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: textColor,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}