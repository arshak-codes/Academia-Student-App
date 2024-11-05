// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:new_project/models/firebase_collections.dart';

import '../../models/task.dart';
import '../../database/database_helper.dart';
import '../../services/firebase_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  static String routeName = 'TasksScreen';

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();
  List<Task> _tasks = [];
  List<dynamic> _upcomingTasks =
      []; // This will hold both tasks and assignments
  double _upcomingOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTasksAndAssignments();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _upcomingOpacity = 1.0;
      });
    });
  }

  Future<void> _loadTasksAndAssignments() async {
    List<Task> tasks = await _dbHelper.getTasks();
    List<Assignment> assignments =
        await _firebaseService.getAssignmentsForClass('Class 11');
    print('Fetched ${assignments.length} assignments from Firebase');

    // Get today's date without time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    setState(() {
      // Filter tasks for today
      _tasks = tasks.where((task) {
        DateTime taskDate = DateTime.parse(task.dueDate);
        DateTime taskDateOnly =
            DateTime(taskDate.year, taskDate.month, taskDate.day);
        return taskDateOnly.isAtSameMomentAs(today);
      }).toList();

      // Filter upcoming tasks
      List<Task> upcomingTasks = tasks.where((task) {
        DateTime taskDate = DateTime.parse(task.dueDate);
        DateTime taskDateOnly =
            DateTime(taskDate.year, taskDate.month, taskDate.day);
        return taskDateOnly.isAfter(today);
      }).toList();

      // Filter upcoming assignments based on due date
      List<Assignment> upcomingAssignments = assignments.where((assignment) {
        try {
          DateTime assignmentDate = DateTime.parse(assignment.dueDate);
          DateTime assignmentDateOnly = DateTime(
              assignmentDate.year, assignmentDate.month, assignmentDate.day);
          return assignmentDateOnly.isAfter(today);
        } catch (e) {
          print('Error parsing date for assignment: ${assignment.title}');
          return false;
        }
      }).toList();

      // Combine and sort upcoming tasks and assignments
      _upcomingTasks = [
        ...upcomingTasks,
        ...upcomingAssignments,
      ]..sort((a, b) {
          DateTime dateA;
          DateTime dateB;

          if (a is Task) {
            dateA = DateTime.parse(a.dueDate);
          } else {
            Assignment assignment = a as Assignment;
            dateA = DateTime.parse(assignment.dueDate);
          }

          if (b is Task) {
            dateB = DateTime.parse(b.dueDate);
          } else {
            Assignment assignment = b as Assignment;
            dateB = DateTime.parse(assignment.dueDate);
          }

          return dateA.compareTo(dateB);
        });

      print('Today\'s tasks: ${_tasks.length}');
      print('Upcoming tasks: ${upcomingTasks.length}');
      print('Upcoming assignments: ${upcomingAssignments.length}');
      print('Combined upcoming items: ${_upcomingTasks.length}');
    });
  }

  void _addTask() async {
    String title = '';
    String description = '';
    String dueDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: Colors.grey[800],
            textTheme: ThemeData.dark().textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
          ),
          child: AlertDialog(
            title: const Text('Add Task',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => title = value,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: 16),
                      Text('Due Date: $dueDate',
                          style: const TextStyle(color: Colors.white)),
                      ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (date != null) {
                            setDialogState(() {
                              dueDate = DateFormat('yyyy-MM-dd').format(date);
                            });
                          }
                        },
                        child: const Text('Select Due Date'),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    final task = Task(
                      title: title,
                      description: description,
                      dueDate: dueDate,
                      isCompleted: false,
                    );
                    await _dbHelper.insertTask(task);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {
                        _loadTasksAndAssignments();
                      });
                    }
                  }
                },
                child: const Text('Add'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUrgencyEmoji(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return '⚠️'; // Overdue
    if (difference == 0) return '🔥'; // Due today
    if (difference <= 3) return '⚡'; // Due soon
    return '📅'; // Due later
  }

  Widget _buildTaskList(List<dynamic> items, bool isToday) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isAssignment = item is Assignment;

        String title = isAssignment ? item.title : item.title;
        String subtitle = isAssignment
            ? '${item.subject} - Due: ${_formatDate(item.dueDate)}'
            : '${item.description} - Due: ${item.dueDate}';

        return Card(
          color: Colors.white.withOpacity(0.8),
          child: ListTile(
            leading: Icon(
              isAssignment ? Icons.assignment : Icons.task,
              color: isAssignment ? Colors.orange : Colors.blue,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: !isAssignment && isToday
                ? IconButton(
                    icon: Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: item.isCompleted ? Colors.green : null,
                      size: 18,
                    ),
                    onPressed: () {
                      Task updatedTask = Task(
                        id: item.id,
                        title: item.title,
                        description: item.description,
                        dueDate: item.dueDate,
                        isCompleted: !item.isCompleted,
                      );
                      _dbHelper.updateTask(updatedTask);
                      _loadTasksAndAssignments();
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Reduced font size
                  ),
                ),
                actions: const [],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reduced padding
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today: $today',
                          style: const TextStyle(
                            fontSize: 16, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12), // Reduced height
                        AnimatedOpacity(
                          opacity: _upcomingOpacity,
                          duration: const Duration(seconds: 2),
                          child: const Text(
                            'Tasks For Today 📅',
                            style: TextStyle(
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _tasks.isEmpty
                            ? const Text(
                                'No tasks for today ☕😊.',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14), // Reduced font size
                              )
                            : SizedBox(
                                height: 160, // Reduced height for task list
                                child: _buildTaskList(_tasks, true),
                              ),
                        const Divider(
                          color: Colors.white,
                          height: 20, // Reduced height
                        ),
                        const Text(
                          'Upcoming Tasks 📅',
                          style: TextStyle(
                            fontSize: 16, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _upcomingTasks.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No upcoming tasks 🎉.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14), // Reduced font size
                                  ),
                                )
                              : _buildTaskList(_upcomingTasks, false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
