// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../models/task.dart';
import '../../database/database_helper.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  static String routeName = 'TasksScreen';

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  List<Task> _upcomingTasks = [];
  double _upcomingOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _upcomingOpacity = 1.0;
      });
    });
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await _dbHelper.getTasks();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      _tasks = tasks.where((task) => task.dueDate == today).toList();
      _upcomingTasks = tasks.where((task) => task.dueDate != today).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
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
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => title = value,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: 8),
                      Text('Due Date: $dueDate',
                          style: const TextStyle(color: Colors.white)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                        ),
                        onPressed: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              );
                            },
                          );

                          if (selectedDate != null) {
                            setState(() {
                              dueDate =
                                  DateFormat('yyyy-MM-dd').format(selectedDate);
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
                onPressed: () {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    final newTask = Task(
                      title: title,
                      description: description,
                      dueDate: dueDate,
                      isCompleted: false,
                    );
                    _dbHelper.insertTask(newTask);
                    _loadTasks();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields.'),
                      ),
                    );
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUrgencyEmoji(String dueDate) {
    DateTime taskDate = DateFormat('yyyy-MM-dd').parse(dueDate);
    DateTime now = DateTime.now();
    Duration difference = taskDate.difference(now);

    if (difference.inDays == 0) return '🔴'; // Urgent (today)
    if (difference.inDays == 1) return '🟠'; // High urgency (tomorrow)
    if (difference.inDays <= 3) return '🟡'; // Medium urgency (within 3 days)
    return '🟢'; // Low urgency (more than 3 days)
  }

  Widget _buildTaskList(List<Task> tasks, bool isToday) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        AnimationController controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: Offset(isToday ? -1.0 : 1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));

        controller.forward();

        return SlideTransition(
          position: offsetAnimation,
          child: Card(
            color: Colors.white.withOpacity(0.8),
            child: ListTile(
              title: Text(
                isToday
                    ? task.title
                    : '${_getUrgencyEmoji(task.dueDate)} ${task.title}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14), // Reduced font size
              ),
              subtitle: Text(
                isToday ? task.description : 'Due on: ${task.dueDate}',
                style: const TextStyle(fontSize: 12), // Reduced font size
              ),
              trailing: isToday
                  ? IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: task.isCompleted ? Colors.green : null,
                        size: 18, // Reduced size
                      ),
                      onPressed: () {
                        // Toggle completion status
                        Task updatedTask = Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          dueDate: task.dueDate,
                          isCompleted: !task.isCompleted,
                        );
                        _dbHelper.updateTask(updatedTask);
                        _loadTasks();
                      },
                    )
                  : null,
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task',
                        style: TextStyle(fontSize: 16)), // Reduced font size
                    content: const Text(
                        'Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _dbHelper.deleteTask(task.id!);
                          _loadTasks();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
