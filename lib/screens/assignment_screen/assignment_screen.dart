import 'package:new_project/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'widgets/assignment_widgets.dart';
import 'package:new_project/services/firebase_service.dart';
import 'package:new_project/models/firebase_collections.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});
  static String routeName = 'AssignmentScreen';

  @override
  _AssignmentScreenState createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('Fetching assignments...'); // Debug print
      final assignments = await _firebaseService.getAssignmentsForClass('R5 A');
      print('Fetched ${assignments.length} assignments'); // Debug print

      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading assignments: $e'); // Debug print
      setState(() {
        _error = 'Failed to load assignments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_assignments.isEmpty) {
      return const Center(
        child: Text('No assignments found'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: kOtherColor,
              borderRadius: kTopBorderRadius,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(kDefaultPadding),
              itemCount: _assignments.length,
              itemBuilder: (context, int index) {
                final assignment = _assignments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: AssignmentCard(assignment: assignment),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Create a separate widget for the assignment card
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const AssignmentCard({Key? key, required this.assignment}) : super(key: key);

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kDefaultPadding),
        color: kOtherColor,
        boxShadow: const [
          BoxShadow(
            color: kTextLightColor,
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(kDefaultPadding),
            ),
            child: Center(
              child: Text(
                assignment.subject,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          kHalfSizedBox,
          Text(
            assignment.title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          kHalfSizedBox,
          AssignmentDetailRow(
            title: 'Assign Date',
            statusValue: _formatDate(assignment.createdAt),
          ),
          kHalfSizedBox,
          AssignmentDetailRow(
            title: 'Due Date',
            statusValue: _formatDate(assignment.dueDate),
          ),
          kHalfSizedBox,
          AssignmentDetailRow(
            title: 'Max Marks',
            statusValue: assignment.maxMarks.toString(),
          ),
          kHalfSizedBox,
          AssignmentDetailRow(
            title: 'Status',
            statusValue: assignment.status,
          ),
          kHalfSizedBox,
          if (assignment.status == 'Pending')
            AssignmentButton(
              onPress: () {
                // submit here
              },
              title: 'To be Submitted',
            ),
        ],
      ),
    );
  }
}
