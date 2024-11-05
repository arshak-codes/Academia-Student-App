import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/assignment.dart';

class AddAssignmentDialog extends StatefulWidget {
  final Assignment? assignment;

  const AddAssignmentDialog({super.key, this.assignment});

  @override
  State<AddAssignmentDialog> createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<AddAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMarksController = TextEditingController();
  DateTime? _dueDate;
  String _selectedClass = 'Class 10';
  List<String> _attachments = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      _subjectController.text = widget.assignment!.subject;
      _titleController.text = widget.assignment!.title;
      _descriptionController.text = widget.assignment!.description;
      _maxMarksController.text = widget.assignment!.maxMarks.toString();
      _dueDate = widget.assignment!.dueDate;
      _selectedClass = widget.assignment!.className;
      _attachments = List.from(widget.assignment!.attachments);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      String filePath = result.files.single.path!;
      setState(() {
        _attachments.add(filePath);
      });
    }
  }

  Future<void> _uploadFiles() async {
    setState(() {
      _isUploading = true;
    });

    try {
      for (String filePath in _attachments) {
        final fileName = filePath.split('/').last;
        final storageRef =
            FirebaseStorage.instance.ref().child('assignments/$fileName');
        await storageRef.putFile(File(filePath));
      }
    } catch (e) {
      // Handle upload errors here
      print('Upload error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_dueDate == null) {
        // Optionally, show a warning or an error message about the due date
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date.')),
        );
        return;
      }

      final newAssignment = Assignment(
        subject: _subjectController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        maxMarks: int.parse(_maxMarksController.text),
        dueDate: _dueDate!, // Use the non-null assertion operator
        className: _selectedClass,
        attachments: _attachments, teacherId: '',
      );

      if (_attachments.isNotEmpty) {
        _uploadFiles();
      }

      Navigator.of(context).pop(newAssignment);
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.assignment == null
                    ? 'Add Assignment'
                    : 'Edit Assignment',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _maxMarksController,
                decoration: const InputDecoration(
                  labelText: 'Max Marks',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                items: ['Class 10', 'Class 11', 'Class 12', 'R5 A', 'R5 B']
                    .map((className) => DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _selectDueDate(context),
                child: Text(_dueDate != null
                    ? 'Due Date: ${_dueDate!.toLocal()}'.split(' ')[0]
                    : 'Select Due Date'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _pickFile,
                child: const Text('Attach File'),
              ),
              const SizedBox(height: 8),
              if (_attachments.isNotEmpty)
                ..._attachments.map((attachment) => Text(attachment)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _submit,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
