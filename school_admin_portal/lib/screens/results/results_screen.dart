import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/result.dart';
import 'add_result_dialog.dart';
import 'view_result_dialog.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedClass;
  String? _selectedExamType;
  String? _selectedSemester;

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
                  'Results',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _importFromExcel,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Import Excel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _exportToExcel,
                      icon: const Icon(Icons.download),
                      label: const Text('Export Excel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddResultDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Result'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildResultsTable(),
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
            items: [
              const DropdownMenuItem(value: null, child: Text('All Classes')),
              ...['Class 10', 'Class 11', 'Class 12'].map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedClass = value),
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
            items: [
              const DropdownMenuItem(value: null, child: Text('All Exams')),
              ...['Mid-term', 'Final', 'Unit Test'].map(
                (e) => DropdownMenuItem(value: e, child: Text(e)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedExamType = value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              labelText: 'Semester',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Semesters')),
              ...['Semester 1', 'Semester 2'].map(
                (s) => DropdownMenuItem(value: s, child: Text(s)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedSemester = value),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs.map((doc) {
          return Result.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Student Name')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Exam Type')),
              DataColumn(label: Text('Semester')),
              DataColumn(label: Text('Percentage')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: results.map((result) {
              return DataRow(
                cells: [
                  DataCell(Text(result.studentName)),
                  DataCell(Text(result.className)),
                  DataCell(Text(result.examType)),
                  DataCell(Text(result.semester)),
                  DataCell(Text('${result.percentage.toStringAsFixed(2)}%')),
                  DataCell(Text(result.overallGrade)),
                  DataCell(Text(result.rank.toString())),
                  DataCell(Text(result.isPublished ? 'Published' : 'Draft')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _viewResult(result),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editResult(result),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteResult(result),
                      ),
                      if (!result.isPublished)
                        IconButton(
                          icon: const Icon(Icons.publish),
                          onPressed: () => _publishResult(result),
                        ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    Query query = _firestore
        .collection('results')
        .orderBy('declaredDate', descending: true);

    if (_selectedClass != null) {
      query = query.where('className', isEqualTo: _selectedClass);
    }
    if (_selectedExamType != null) {
      query = query.where('examType', isEqualTo: _selectedExamType);
    }
    if (_selectedSemester != null) {
      query = query.where('semester', isEqualTo: _selectedSemester);
    }

    return query.snapshots();
  }

  Future<void> _showAddResultDialog(BuildContext context) async {
    final result = await showDialog<Result>(
      context: context,
      builder: (context) => const AddResultDialog(),
    );

    if (result != null) {
      await _firestore.collection('results').add(result.toMap());
    }
  }

  Future<void> _viewResult(Result result) async {
    await showDialog(
      context: context,
      builder: (context) => ViewResultDialog(result: result),
    );
  }

  Future<void> _editResult(Result result) async {
    final updatedResult = await showDialog<Result>(
      context: context,
      builder: (context) => AddResultDialog(result: result),
    );

    if (updatedResult != null) {
      await _firestore
          .collection('results')
          .doc(result.id)
          .update(updatedResult.toMap());
    }
  }

  Future<void> _deleteResult(Result result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Result'),
        content: const Text('Are you sure you want to delete this result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('results').doc(result.id).delete();
    }
  }

  Future<void> _publishResult(Result result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Result'),
        content: const Text('Are you sure you want to publish this result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore
          .collection('results')
          .doc(result.id)
          .update({'isPublished': true});
    }
  }

  Future<void> _importFromExcel() async {
    // Implementation for importing results from Excel
  }

  Future<void> _exportToExcel() async {
    // Implementation for exporting results to Excel
  }
}
