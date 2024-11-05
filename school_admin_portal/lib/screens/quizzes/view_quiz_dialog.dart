import 'package:flutter/material.dart';
import '../../models/quiz.dart';

class ViewQuizDialog extends StatelessWidget {
  final Quiz quiz;

  const ViewQuizDialog({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(context),
                    const SizedBox(height: 24),
                    Text(
                      'Questions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionsList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Subject:', quiz.subject),
            _buildInfoRow('Class:', quiz.className),
            _buildInfoRow('Duration:', '${quiz.duration} minutes'),
            _buildInfoRow('Total Marks:', quiz.totalMarks.toString()),
            _buildInfoRow(
                'Start Time:', quiz.startTime.toString().split('.')[0]),
            _buildInfoRow('End Time:', quiz.endTime.toString().split('.')[0]),
            _buildInfoRow('Status:', quiz.isPublished ? 'Published' : 'Draft'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quiz.questions.length,
      itemBuilder: (context, index) {
        final question = quiz.questions[index];
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
                if (question.type == QuestionType.multipleChoice)
                  ...question.options.map((option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              option == question.correctAnswer
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: option == question.correctAnswer
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(option),
                          ],
                        ),
                      )),
                if (question.type != QuestionType.multipleChoice)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Correct Answer: ${question.correctAnswer}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Marks: ${question.marks}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
