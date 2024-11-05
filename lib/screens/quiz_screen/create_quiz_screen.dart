import 'package:flutter/material.dart';
import 'package:new_project/models/quiz.dart';
import 'package:new_project/services/firebase_service.dart';
import 'package:intl/intl.dart';

class CreateQuizScreen extends StatefulWidget {
  static String routeName = 'CreateQuizScreen';

  const CreateQuizScreen({Key? key}) : super(key: key);

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String title = '';
  String subject = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 1));
  int duration = 30;
  List<Question> questions = [];

  void _addQuestion() {
    setState(() {
      questions.add(
        Question(
          question: '',
          options: ['', '', '', ''],
          correctAnswer: 0,
          marks: 1,
        ),
      );
    });
  }

  Future<void> _createQuiz() async {
    if (_formKey.currentState!.validate() && questions.isNotEmpty) {
      try {
        final quiz = Quiz(
          id: '',
          title: title,
          subject: subject,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
          questions: questions,
          className: 'Class 11', // You might want to make this dynamic
        );

        await _firebaseService.createQuiz(quiz);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating quiz: $e')),
        );
      }
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? startTime : endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartTime ? startTime : endTime),
      );
      if (time != null) {
        setState(() {
          if (isStartTime) {
            startTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          } else {
            endTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quiz Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
              onChanged: (value) => title = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a subject' : null,
              onChanged: (value) => subject = value,
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(startTime)),
              onTap: () => _selectDateTime(true),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(endTime)),
              onTap: () => _selectDateTime(false),
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
              initialValue: '30',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
              onChanged: (value) => duration = int.tryParse(value) ?? 30,
            ),
            const SizedBox(height: 16),
            const Text(
              'Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...List.generate(
              questions.length,
              (index) => _buildQuestionCard(index),
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: questions.isEmpty ? null : _createQuiz,
              child: const Text('Create Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${index + 1}'),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      questions.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Question'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a question' : null,
              onChanged: (value) => questions[index] = Question(
                question: value,
                options: questions[index].options,
                correctAnswer: questions[index].correctAnswer,
                marks: questions[index].marks,
              ),
            ),
            ...List.generate(
              4,
              (optionIndex) => TextFormField(
                decoration:
                    InputDecoration(labelText: 'Option ${optionIndex + 1}'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter an option' : null,
                onChanged: (value) {
                  final newOptions =
                      List<String>.from(questions[index].options);
                  newOptions[optionIndex] = value;
                  questions[index] = Question(
                    question: questions[index].question,
                    options: newOptions,
                    correctAnswer: questions[index].correctAnswer,
                    marks: questions[index].marks,
                  );
                },
              ),
            ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Correct Answer'),
              value: questions[index].correctAnswer,
              items: List.generate(
                4,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text('Option ${i + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    questions[index] = Question(
                      question: questions[index].question,
                      options: questions[index].options,
                      correctAnswer: value,
                      marks: questions[index].marks,
                    );
                  });
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Marks'),
              keyboardType: TextInputType.number,
              initialValue: '1',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter marks';
                }
                final marks = int.tryParse(value);
                if (marks == null || marks <= 0) {
                  return 'Please enter valid marks';
                }
                return null;
              },
              onChanged: (value) {
                questions[index] = Question(
                  question: questions[index].question,
                  options: questions[index].options,
                  correctAnswer: questions[index].correctAnswer,
                  marks: int.tryParse(value) ?? 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
