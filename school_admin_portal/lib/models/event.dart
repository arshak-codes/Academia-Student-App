enum EventType { academic, cultural, sports, examination, holiday, other }

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final EventType type;
  final List<String> targetClasses;
  final String organizerId;
  final String organizerName;
  final List<String> attachments;
  final bool isPublished;
  final DateTime createdAt;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.type,
    required this.targetClasses,
    required this.organizerId,
    required this.organizerName,
    this.attachments = const [],
    this.isPublished = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'venue': venue,
      'type': type.toString(),
      'targetClasses': targetClasses,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'attachments': attachments,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      venue: map['venue'],
      type: EventType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      targetClasses: List<String>.from(map['targetClasses']),
      organizerId: map['organizerId'],
      organizerName: map['organizerName'],
      attachments: List<String>.from(map['attachments']),
      isPublished: map['isPublished'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
