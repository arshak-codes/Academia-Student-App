import 'package:flutter/material.dart';
import '../../models/result.dart';

class AddResultDialog extends StatefulWidget {
  final Result? result;

  const AddResultDialog({super.key, this.result});

  @override
  State<AddResultDialog> createState() => _AddResultDialogState();
}

class _AddResultDialogState extends State<AddResultDialog> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedClass = 'Class 10';
  String _selectedExamType = 'Mid-term';
  String _selectedSemester = 'Semester 1';
  DateTime? _examDate;
  DateTime? _declaredDate;

  final List<Map<String, TextEditingController>> _subjectControllers = [];
  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'Language',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.result != null) {
      _studentNameController.text = widget.result!.studentName;
      _studentIdController.text = widget.result!.studentId;
      _selectedClass = widget.result!.className;
      _selectedExamType = widget.result!.examType;
      _selectedSemester = widget.result!.semester;
      _examDate = widget.result!.examDate;
      _declaredDate = widget.result!.declaredDate;

      // Initialize subject controllers with existing data
      for (var subject in widget.result!.subjects) {
        _addSubjectControllers(
          subject.subject,
          subject.marksObtained.toString(),
          subject.totalMarks.toString(),
          subject.remarks,
        );
      }
    } else {
      // Add default subject controllers
      for (var subject in _subjects) {
        _addSubjectControllers(subject, '', '', '');
      }
    }
  }

  void _addSubjectControllers(
    String subject,
    String marks,
    String total,
    String remarks,
  ) {
    _subjectControllers.add({
      'subject': TextEditingController(text: subject),
      'marks': TextEditingController(text: marks),
      'total': TextEditingController(text: total),
      'remarks': TextEditingController(text: remarks),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.result == null ? 'Add Result' : 'Edit Result',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _buildStudentInfo(),
                const SizedBox(height: 16),
                _buildExamInfo(),
                const SizedBox(height: 24),
                Text(
                  'Subject Marks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildSubjectsTable(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveResult,
                      child: Text(
                        widget.result == null ? 'Add Result' : 'Update Result',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _studentNameController,
            decoration: const InputDecoration(
              labelText: 'Student Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _studentIdController,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 16),
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
      ],
    );
  }

  Widget _buildExamInfo() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedExamType,
            decoration: const InputDecoration(
              labelText: 'Exam Type',
              border: OutlineInputBorder(),
            ),
            items: ['Mid-term', 'Final', 'Unit Test']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedExamType = value);
              }
            },
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
            items: ['Semester 1', 'Semester 2']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSemester = value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Exam Date',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _examDate == null
                    ? 'Select Date'
                    : _examDate.toString().split(' ')[0],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Declaration Date',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _declaredDate == null
                    ? 'Select Date'
                    : _declaredDate.toString().split(' ')[0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      border: TableBorder.all(),
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Subject',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text('Marks', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Remarks',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        ..._subjectControllers.map((controllers) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controllers['subject'],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controllers['marks'],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controllers['total'],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controllers['remarks'],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _selectDate(bool isExamDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (date != null) {
      setState(() {
        if (isExamDate) {
          _examDate = date;
        } else {
          _declaredDate = date;
        }
      });
    }
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'F';
  }

  void _saveResult() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_examDate == null || _declaredDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both dates')),
        );
        return;
      }

      final subjects = _subjectControllers.map((controllers) {
        final marksObtained = int.parse(controllers['marks']!.text);
        final totalMarks = int.parse(controllers['total']!.text);
        final percentage = (marksObtained / totalMarks) * 100;

        return SubjectResult(
          subject: controllers['subject']!.text,
          marksObtained: marksObtained,
          totalMarks: totalMarks,
          grade: _calculateGrade(percentage),
          remarks: controllers['remarks']!.text,
        );
      }).toList();

      // Calculate overall percentage
      final totalObtained = subjects.fold<int>(
        0,
        (sum, subject) => sum + subject.marksObtained,
      );
      final totalMarks = subjects.fold<int>(
        0,
        (sum, subject) => sum + subject.totalMarks,
      );
      final percentage = (totalObtained / totalMarks) * 100;

      final result = Result(
        id: widget.result?.id,
        studentId: _studentIdController.text,
        studentName: _studentNameController.text,
        className: _selectedClass,
        examType: _selectedExamType,
        semester: _selectedSemester,
        subjects: subjects,
        percentage: percentage,
        overallGrade: _calculateGrade(percentage),
        rank: 0, // Will be calculated later
        examDate: _examDate!,
        declaredDate: _declaredDate!,
      );

      Navigator.pop(context, result);
    }
  }

  @override
  void dispose() {
    for (var controllers in _subjectControllers) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
