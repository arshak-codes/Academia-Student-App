import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/quiz.dart';
import 'add_quiz_dialog.dart';
import 'view_quiz_dialog.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quizzes',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddQuizDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Quiz'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('quizzes')
                    .orderBy('startTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final quizzes = snapshot.data!.docs.map((doc) {
                    return Quiz.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>);
                  }).toList();

                  return _buildQuizzesTable(quizzes);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizzesTable(List<Quiz> quizzes) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Start Time')),
          DataColumn(label: Text('Duration')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: quizzes.map((quiz) {
          return DataRow(
            cells: [
              DataCell(Text(quiz.subject)),
              DataCell(Text(quiz.title)),
              DataCell(Text(quiz.className)),
              DataCell(Text(quiz.startTime.toString().split('.')[0])),
              DataCell(Text('${quiz.duration} mins')),
              DataCell(Text(quiz.isPublished ? 'Published' : 'Draft')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _viewQuiz(quiz),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editQuiz(quiz),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteQuiz(quiz),
                  ),
                  if (!quiz.isPublished)
                    IconButton(
                      icon: const Icon(Icons.publish),
                      onPressed: () => _publishQuiz(quiz),
                    ),
                  IconButton(
                    icon: const Icon(Icons.assessment),
                    onPressed: () => _viewResults(quiz),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showAddQuizDialog(BuildContext context) async {
    final result = await showDialog<Quiz>(
      context: context,
      builder: (context) => const AddQuizDialog(),
    );

    if (result != null) {
      await _firestore.collection('quizzes').add(result.toMap());
    }
  }

  Future<void> _viewQuiz(Quiz quiz) async {
    await showDialog(
      context: context,
      builder: (context) => ViewQuizDialog(quiz: quiz),
    );
  }

  Future<void> _editQuiz(Quiz quiz) async {
    // Implement edit quiz functionality
  }

  Future<void> _deleteQuiz(Quiz quiz) async {
    // Implement delete quiz functionality
  }

  Future<void> _publishQuiz(Quiz quiz) async {
    // Implement publish quiz functionality
  }

  Future<void> _viewResults(Quiz quiz) async {
    // Implement view results functionality
  }
}
