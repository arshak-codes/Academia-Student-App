import 'package:flutter/material.dart';
import 'package:new_project/models/quiz.dart';
import 'package:new_project/services/firebase_service.dart';
import 'package:new_project/screens/quiz_screen/take_quiz_screen.dart';
import 'package:new_project/screens/quiz_screen/create_quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  static String routeName = 'QuizListScreen';

  const QuizListScreen({Key? key}) : super(key: key);

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final quizzes = await _firebaseService.getAvailableQuizzes('Class 11');
      setState(() {
        _quizzes = quizzes
            .map((quiz) =>
                Quiz.fromMap(quiz, 'Class 11' as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quizzes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                CreateQuizScreen.routeName,
              );
              _loadQuizzes(); // Reload quizzes after creating new one
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? const Center(
                  child: Text('No quizzes available'),
                )
              : ListView.builder(
                  itemCount: _quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    final bool isAvailable =
                        quiz.startTime.isBefore(DateTime.now()) &&
                            quiz.endTime.isAfter(DateTime.now());

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(quiz.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz.subject),
                            Text(
                              'Duration: ${quiz.duration} minutes',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Available: ${_formatDateTime(quiz.startTime)} - ${_formatDateTime(quiz.endTime)}',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: isAvailable
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    TakeQuizScreen.routeName,
                                    arguments: quiz,
                                  );
                                }
                              : null,
                          child: Text(
                            isAvailable ? 'Take Quiz' : 'Not Available',
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
