import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/assignment.dart';
import 'add_assignment_dialog.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
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
                  'Assignments',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAssignmentDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Assignment'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('assignments')
                    .orderBy('dueDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final assignments = snapshot.data!.docs.map((doc) {
                    return Assignment.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>);
                  }).toList();

                  return _buildAssignmentsTable(assignments);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsTable(List<Assignment> assignments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Due Date')),
          DataColumn(label: Text('Max Marks')),
          DataColumn(label: Text('Actions')),
        ],
        rows: assignments.map((assignment) {
          return DataRow(
            cells: [
              DataCell(Text(assignment.subject)),
              DataCell(Text(assignment.title)),
              DataCell(Text(assignment.className)),
              DataCell(Text(assignment.dueDate.toString().split(' ')[0])),
              DataCell(Text(assignment.maxMarks.toString())),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editAssignment(assignment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteAssignment(assignment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _viewSubmissions(assignment),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showAddAssignmentDialog(BuildContext context) async {
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => const AddAssignmentDialog(),
    );

    if (result != null) {
      await _firestore.collection('assignments').add(result.toMap());
    }
  }

  Future<void> _editAssignment(Assignment assignment) async {
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => AddAssignmentDialog(assignment: assignment),
    );

    if (result != null) {
      await _firestore
          .collection('assignments')
          .doc(assignment.id)
          .update(result.toMap());
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    await _firestore.collection('assignments').doc(assignment.id).delete();
  }

  Future<void> _viewSubmissions(Assignment assignment) async {
    // Implement view submissions functionality
  }
}
