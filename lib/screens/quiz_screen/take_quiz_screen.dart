import 'package:flutter/material.dart';
import 'package:new_project/models/quiz.dart';
import 'dart:async';

class TakeQuizScreen extends StatefulWidget {
  static String routeName = 'TakeQuizScreen';

  const TakeQuizScreen({Key? key}) : super(key: key);

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late Quiz quiz;
  int currentQuestionIndex = 0;
  List<int?> answers = [];
  late Timer _timer;
  int _timeRemaining = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
      answers = List.filled(quiz.questions.length, null);
      _timeRemaining = quiz.duration * 60;
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    _timer.cancel();
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (answers[i] == quiz.questions[i].correctAnswer) {
        score += quiz.questions[i].marks;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Your score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                ModalRoute.withName(Navigator.defaultRouteName),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining == 0) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time: ${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${quiz.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              quiz.questions[currentQuestionIndex].question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              quiz.questions[currentQuestionIndex].options.length,
              (index) => RadioListTile<int>(
                title:
                    Text(quiz.questions[currentQuestionIndex].options[index]),
                value: index,
                groupValue: answers[currentQuestionIndex],
                onChanged: (value) {
                  setState(() {
                    answers[currentQuestionIndex] = value;
                  });
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                if (currentQuestionIndex < quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    },
                    child: const Text('Next'),
                  ),
                if (currentQuestionIndex == quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: _submitQuiz,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
