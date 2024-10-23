class Task {
  final int? id;
  final String title;
  final String description;
  final String dueDate;
  final bool isCompleted;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.dueDate,
      required this.isCompleted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
