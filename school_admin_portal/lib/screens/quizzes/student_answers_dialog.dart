import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/quiz_result.dart';

class StudentAnswersDialog extends StatelessWidget {
  final Quiz quiz;
  final QuizResult result;

  const StudentAnswersDialog({
    super.key,
    required this.quiz,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Student Answers: ${result.studentName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  final studentAnswer =
                      result.answers[question.id] ?? 'Not answered';
                  final isCorrect = studentAnswer == question.correctAnswer;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. ${question.text}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Student Answer: $studentAnswer'),
                                    if (!isCorrect)
                                      Text(
                                        'Correct Answer: ${question.correctAnswer}',
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
