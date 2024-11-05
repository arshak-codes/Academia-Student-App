import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final List<Question> questions;
  final bool isActive;
  final String className;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.questions,
    required this.className,
    this.isActive = true,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      duration: map['duration'] ?? 30,
      questions: (map['questions'] as List<dynamic>)
          .map((q) => Question.fromMap(q))
          .toList(),
      className: map['className'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'duration': duration,
      'questions': questions.map((q) => q.toMap()).toList(),
      'className': className,
      'isActive': isActive,
    };
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int marks;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.marks,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      marks: map['marks'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'marks': marks,
    };
  }
}
