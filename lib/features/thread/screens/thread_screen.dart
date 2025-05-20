import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../shared/navigation/bottom_nav_bar.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({Key? key}) : super(key: key);

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  int _currentIndex = 2; // Thread selected
  String _selectedThread = '#YOUR-PROJECT-SPACE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedThread),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      drawer: _buildThreadDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Thread messages
                _buildThreadMessage(
                  sender: 'Dacia Emanuel',
                  message: 'Content of message.',
                  time: '9:15 AM',
                  avatar: 'DE',
                ),
                const SizedBox(height: 16),
                _buildThreadMessage(
                  sender: 'Dacia Emanuel',
                  message: 'Content of message.',
                  time: '9:18 AM',
                  avatar: 'DE',
                ),
              ],
            ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'This is an example message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
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
              // Already on Thread
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildThreadDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: const [
                Icon(Icons.chat_bubble, color: AppColors.primary),
                SizedBox(width: 8),
                Text('thread', style: AppTextStyles.heading3),
              ],
            ),
          ),
          // HQ Section
          ListTile(
            title: const Text('#HQ', style: TextStyle(fontWeight: FontWeight.bold)),
            dense: true,
          ),
          ListTile(
            leading: const Text('#'),
            title: const Text('lobby'),
            dense: true,
            onTap: () {
              setState(() {
                _selectedThread = '#lobby';
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Text('#'),
            title: const Text('announcement'),
            dense: true,
            onTap: () {
              setState(() {
                _selectedThread = '#announcement';
              });
              Navigator.pop(context);
            },
          ),
          
          // PROJECT-THREADS Section
          const Divider(),
          ListTile(
            title: const Text('#PROJECT-THREADS', style: TextStyle(fontWeight: FontWeight.bold)),
            dense: true,
          ),
          ListTile(
            leading: const Text('#'),
            title: const Text('YOUR-PROJECT-SPACE'),
            dense: true,
            selected: _selectedThread == '#YOUR-PROJECT-SPACE',
            selectedTileColor: AppColors.primary.withOpacity(0.1),
            onTap: () {
              setState(() {
                _selectedThread = '#YOUR-PROJECT-SPACE';
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Text('#'),
            title: const Text('YOUR-PROJECT-SPACE'),
            dense: true,
            onTap: () {
              setState(() {
                _selectedThread = '#YOUR-PROJECT-SPACE';
              });
              Navigator.pop(context);
            },
          ),
          
          // Spacer and bottom section
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text('S', style: TextStyle(color: Colors.white)),
            ),
            title: const Text('Sinister'),
            onTap: () {
              // Profile action
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              // Logout action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThreadMessage({
    required String sender,
    required String message,
    required String time,
    required String avatar,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(avatar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    sender,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(message),
            ],
          ),
        ),
      ],
    );
  }
}