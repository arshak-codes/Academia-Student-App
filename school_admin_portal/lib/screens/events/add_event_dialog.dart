import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/event.dart';

class AddEventDialog extends StatefulWidget {
  final Event? event;

  const AddEventDialog({super.key, this.event});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  EventType _selectedType = EventType.academic;
  List<String> _selectedClasses = [];
  List<String> _attachments = [];
  bool _isUploading = false;

  final List<String> _availableClasses = [
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _venueController.text = widget.event!.venue;
      _startDate = widget.event!.startDate;
      _endDate = widget.event!.endDate;
      _selectedType = widget.event!.type;
      _selectedClasses = List.from(widget.event!.targetClasses);
      _attachments = List.from(widget.event!.attachments);
    }
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
                  widget.event == null ? 'Create Event' : 'Edit Event',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<EventType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(_startDate == null
                            ? 'Select Start Date'
                            : _startDate.toString().split(' ')[0]),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(_endDate == null
                            ? 'Select End Date'
                            : _endDate.toString().split(' ')[0]),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Target Classes'),
                Wrap(
                  spacing: 8,
                  children: _availableClasses.map((className) {
                    return FilterChip(
                      label: Text(className),
                      selected: _selectedClasses.contains(className),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedClasses.add(className);
                          } else {
                            _selectedClasses.remove(className);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add Attachments'),
                    ),
                    if (_isUploading) ...[
                      const SizedBox(width: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _attachments
                        .map((url) => Chip(
                              label: Text(url.split('/').last),
                              onDeleted: () {
                                setState(() {
                                  _attachments.remove(url);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
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
                      onPressed: _isUploading ? null : _saveEvent,
                      child: Text(
                        widget.event == null ? 'Create' : 'Update',
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

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate == null || _endDate!.isBefore(date)) {
            _endDate = date;
          }
        } else {
          if (date.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date cannot be before start date'),
              ),
            );
          } else {
            _endDate = date;
          }
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() => _isUploading = true);
      try {
        for (final file in result.files) {
          final ref = FirebaseStorage.instance.ref().child(
              'events/${DateTime.now().millisecondsSinceEpoch}_${file.name}');

          final uploadTask = ref.putData(file.bytes!);
          final snapshot = await uploadTask;
          final url = await snapshot.ref.getDownloadURL();

          setState(() {
            _attachments.add(url);
          });
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates'),
          ),
        );
        return;
      }

      if (_selectedClasses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one class'),
          ),
        );
        return;
      }

      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        venue: _venueController.text,
        type: _selectedType,
        targetClasses: _selectedClasses,
        organizerId: 'current_teacher_id', // Replace with actual teacher ID
        organizerName: 'Teacher Name', // Replace with actual teacher name
        attachments: _attachments,
      );

      Navigator.pop(context, event);
    }
  }
}
