enum QuestionType { multipleChoice, trueFalse, shortAnswer, essay }

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final int marks;

  Question({
    String? id,
    required this.text,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    required this.marks,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString(),
      'options': options,
      'correctAnswer': correctAnswer,
      'marks': marks,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
      marks: map['marks'],
    );
  }
}

class Quiz {
  final String? id;
  final String subject;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final String className;
  final String teacherId;
  final List<Question> questions;
  final bool isPublished;
  final int totalMarks;

  Quiz({
    this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.className,
    required this.teacherId,
    required this.questions,
    this.isPublished = false,
  }) : totalMarks = questions.fold(0, (sum, q) => sum + q.marks);

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'className': className,
      'teacherId': teacherId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isPublished': isPublished,
      'totalMarks': totalMarks,
    };
  }

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      subject: map['subject'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      duration: map['duration'],
      className: map['className'],
      teacherId: map['teacherId'],
      questions:
          (map['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      isPublished: map['isPublished'] ?? false,
    );
  }
}
