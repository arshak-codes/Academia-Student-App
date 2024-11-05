class Assignment {
  final String? id;
  final String subject;
  final String title;
  final String description;
  final DateTime dueDate;
  final String className;
  final List<String> attachments;
  final String teacherId;
  final DateTime createdAt;
  final int maxMarks;

  Assignment({
    this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.className,
    this.attachments = const [],
    required this.teacherId,
    DateTime? createdAt,
    required this.maxMarks,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'className': className,
      'attachments': attachments,
      'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
      'maxMarks': maxMarks,
    };
  }

  factory Assignment.fromMap(String id, Map<String, dynamic> map) {
    return Assignment(
      id: id,
      subject: map['subject'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      className: map['className'],
      attachments: List<String>.from(map['attachments']),
      teacherId: map['teacherId'],
      createdAt: DateTime.parse(map['createdAt']),
      maxMarks: map['maxMarks'],
    );
  }
}
