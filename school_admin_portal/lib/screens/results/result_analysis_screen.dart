import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/result.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultAnalysisScreen extends StatefulWidget {
  const ResultAnalysisScreen({super.key});

  @override
  State<ResultAnalysisScreen> createState() => _ResultAnalysisScreenState();
}

class _ResultAnalysisScreenState extends State<ResultAnalysisScreen> {
  String _selectedClass = 'Class 10';
  String _selectedExamType = 'Mid-term';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getResultsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = snapshot.data!.docs
                      .map((doc) => Result.fromMap(
                          doc.id, doc.data() as Map<String, dynamic>))
                      .toList();

                  if (results.isEmpty) {
                    return const Center(child: Text('No results found'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBasicStats(results),
                        const SizedBox(height: 24),
                        _buildGradeDistribution(results),
                        const SizedBox(height: 24),
                        _buildTopPerformers(results),
                      ],
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

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
            items: ['Class 10', 'Class 11', 'Class 12']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedClass = value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedExamType,
            decoration: const InputDecoration(
              labelText: 'Exam Type',
              border: OutlineInputBorder(),
            ),
            items: ['Mid-term', 'Final']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedExamType = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBasicStats(List<Result> results) {
    final avgPercentage = results.isEmpty
        ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a + b) /
            results.length;

    final passCount = results.where((r) => r.percentage >= 50).length;
    final passPercentage = (passCount / results.length) * 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'Average Percentage',
          '${avgPercentage.toStringAsFixed(1)}%',
          Icons.percent,
        ),
        _buildStatCard(
          'Total Students',
          results.length.toString(),
          Icons.people,
        ),
        _buildStatCard(
          'Pass Percentage',
          '${passPercentage.toStringAsFixed(1)}%',
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistribution(List<Result> results) {
    final gradeCount = {
      'A+': 0,
      'A': 0,
      'B+': 0,
      'B': 0,
      'C': 0,
      'F': 0,
    };

    for (var result in results) {
      gradeCount[result.overallGrade] =
          (gradeCount[result.overallGrade] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Grade Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: results.length.toDouble(),
                  barGroups: gradeCount.entries.map((entry) {
                    return BarChartGroupData(
                      x: gradeCount.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getGradeColor(entry.key),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(gradeCount.keys.toList()[value.toInt()]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformers(List<Result> results) {
    final sortedResults = List<Result>.from(results)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    final topPerformers = sortedResults.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topPerformers.length,
              itemBuilder: (context, index) {
                final result = topPerformers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(result.studentName),
                  subtitle: Text('Roll No: ${result.studentId}'),
                  trailing: Text(
                    '${result.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getResultsStream() {
    return FirebaseFirestore.instance
        .collection('results')
        .where('className', isEqualTo: _selectedClass)
        .where('examType', isEqualTo: _selectedExamType)
        .snapshots();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.purple;
      case 'A':
        return Colors.blue;
      case 'B+':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }
}
