import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';
import 'add_event_dialog.dart';
import 'view_event_dialog.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  EventType? _selectedType;
  String? _selectedClass;

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
                  'Events',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEventDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildEventsTable(),
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
          child: DropdownButtonFormField<EventType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Filter by Type',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedType = value);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Filter by Class',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Classes'),
              ),
              ...['Class 10', 'Class 11', 'Class 12'].map((className) {
                return DropdownMenuItem(
                  value: className,
                  child: Text(className),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedClass = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs.map((doc) {
          return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Venue')),
              DataColumn(label: Text('Classes')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: events.map((event) {
              return DataRow(
                cells: [
                  DataCell(Text(event.title)),
                  DataCell(Text(event.type.toString().split('.').last)),
                  DataCell(Text(
                    '${DateFormat('MMM d').format(event.startDate)} - ${DateFormat('MMM d').format(event.endDate)}',
                  )),
                  DataCell(Text(event.venue)),
                  DataCell(Text(event.targetClasses.join(', '))),
                  DataCell(Text(event.isPublished ? 'Published' : 'Draft')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _viewEvent(event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editEvent(event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEvent(event),
                      ),
                      if (!event.isPublished)
                        IconButton(
                          icon: const Icon(Icons.publish),
                          onPressed: () => _publishEvent(event),
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
    Query query =
        _firestore.collection('events').orderBy('startDate', descending: true);

    if (_selectedType != null) {
      query = query.where('type', isEqualTo: _selectedType.toString());
    }

    if (_selectedClass != null) {
      query = query.where('targetClasses', arrayContains: _selectedClass);
    }

    return query.snapshots();
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final result = await showDialog<Event>(
      context: context,
      builder: (context) => const AddEventDialog(),
    );

    if (result != null) {
      await _firestore.collection('events').add(result.toMap());
    }
  }

  Future<void> _viewEvent(Event event) async {
    await showDialog(
      context: context,
      builder: (context) => ViewEventDialog(event: event),
    );
  }

  Future<void> _editEvent(Event event) async {
    final result = await showDialog<Event>(
      context: context,
      builder: (context) => AddEventDialog(event: event),
    );

    if (result != null) {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(result.toMap());
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
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
      await _firestore.collection('events').doc(event.id).delete();
    }
  }

  Future<void> _publishEvent(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Event'),
        content: const Text('Are you sure you want to publish this event?'),
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
          .collection('events')
          .doc(event.id)
          .update({'isPublished': true});
    }
  }
}
