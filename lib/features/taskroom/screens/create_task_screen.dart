import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/themes/app_colors.dart';
import '../../../config/themes/app_text_styles.dart';
import '../../../data/models/task_model.dart';
import '../providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskType _taskType = TaskType.deadline;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Generate a simple ID (you might want to use UUID in a real app)
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newTask = TaskModel(
        id: taskId,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _taskType == TaskType.deadline ? _dueDate : null,
        dueTime: _taskType == TaskType.daily ? _dueTime : null,
        isCompleted: false,
        type: _taskType,
        priority: _taskType == TaskType.deadline ? _priority : null,
      );
      
      // Add task using provider
      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      
      // Navigate back
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type Selection
              const Text('Task Type', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTaskTypeCard(
                      icon: Icons.repeat,
                      title: 'Daily Task',
                      description: 'Repeating activity',
                      type: TaskType.daily,
                      isSelected: _taskType == TaskType.daily,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskTypeCard(
                      icon: Icons.calendar_today,
                      title: 'Deadline Task',
                      description: 'One-time task',
                      type: TaskType.deadline,
                      isSelected: _taskType == TaskType.deadline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Task Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Task Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Due Time (for daily tasks)
      if (_taskType == TaskType.daily) ...[
        const Text('Reminder Time', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: _dueTime ?? TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                _dueTime = pickedTime;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  _dueTime == null
                      ? 'Select a time'
                      : '${_dueTime!.format(context)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
              // Due Date (for deadline tasks)
              if (_taskType == TaskType.deadline) ...[
                const Text('Due Date', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dueDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _dueDate == null
                              ? 'Select a date'
                              : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority (for deadline tasks)
                const Text('Priority', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriorityButton('Low', TaskPriority.low),
                    const SizedBox(width: 8),
                    _buildPriorityButton('Medium', TaskPriority.medium),
                    const SizedBox(width: 8),
                    _buildPriorityButton('High', TaskPriority.high),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaskTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required TaskType type,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _taskType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriorityButton(String label, TaskPriority priority) {
    final bool isSelected = _priority == priority;
    
    // Determine color based on priority
    Color priorityColor;
    switch (priority) {
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
    }
    
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _priority = priority;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? priorityColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(color: priorityColor),
        ),
        child: Text(label),
      ),
    );
  }
}