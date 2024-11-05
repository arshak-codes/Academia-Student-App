import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/quiz.dart';
import '../../models/quiz_result.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizAnalyticsDialog extends StatelessWidget {
  final Quiz quiz;

  const QuizAnalyticsDialog({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quiz_results')
              .where('quizId', isEqualTo: quiz.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final results = snapshot.data!.docs
                .map((doc) => QuizResult.fromMap(
                    doc.id, doc.data() as Map<String, dynamic>))
                .toList();

            return Column(
              children: [
                Text(
                  'Quiz Analytics',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildScoreDistribution(results),
                      ),
                      Expanded(
                        child: _buildQuestionAnalysis(results),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSummaryStats(results),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreDistribution(List<QuizResult> results) {
    final Map<String, int> distribution = {
      '0-20': 0,
      '21-40': 0,
      '41-60': 0,
      '61-80': 0,
      '81-100': 0,
    };

    for (var result in results) {
      final percentage = (result.score / quiz.totalMarks) * 100;
      if (percentage <= 20) {
        distribution['0-20'] = (distribution['0-20'] ?? 0) + 1;
      } else if (percentage <= 40)
        distribution['21-40'] = (distribution['21-40'] ?? 0) + 1;
      else if (percentage <= 60)
        distribution['41-60'] = (distribution['41-60'] ?? 0) + 1;
      else if (percentage <= 80)
        distribution['61-80'] = (distribution['61-80'] ?? 0) + 1;
      else
        distribution['81-100'] = (distribution['81-100'] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Score Distribution'),
            Expanded(
              child: BarChart(
                BarChartData(
                    // Implementation of bar chart data
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnalysis(List<QuizResult> results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Question-wise Analysis'),
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  int correctAnswers = 0;

                  for (var result in results) {
                    if (result.answers[question.id] == question.correctAnswer) {
                      correctAnswers++;
                    }
                  }

                  final percentage = (correctAnswers / results.length) * 100;

                  return ListTile(
                    title: Text('Q${index + 1}'),
                    subtitle: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                    trailing: Text('${percentage.toStringAsFixed(1)}%'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<QuizResult> results) {
    final avgScore = results.isEmpty
        ? 0.0
        : results.map((r) => r.score).reduce((a, b) => a + b) / results.length;

    final avgTime = results.isEmpty
        ? Duration.zero
        : Duration(
            seconds: results
                    .map((r) => r.timeTaken.inSeconds)
                    .reduce((a, b) => a + b) ~/
                results.length,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard('Total Submissions', '${results.length}'),
        _buildStatCard('Average Score',
            '${avgScore.toStringAsFixed(1)}/${quiz.totalMarks}'),
        _buildStatCard('Average Time',
            '${avgTime.inMinutes}:${(avgTime.inSeconds % 60).toString().padLeft(2, '0')}'),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
