// Collection names
import 'package:cloud_firestore/cloud_firestore.dart';

const String USERS_COLLECTION = 'users';
const String ASSIGNMENTS_COLLECTION = 'assignments';
const String QUIZZES_COLLECTION = 'quizzes';
const String RESULTS_COLLECTION = 'results';
const String EVENTS_COLLECTION = 'events';

// Document structure for each collection
class Assignment {
  final String id;
  final String title;
  final String subject;
  final String createdAt;
  final String dueDate;
  final int maxMarks;
  final String status;
  final String className;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.createdAt,
    required this.dueDate,
    required this.maxMarks,
    required this.status,
    required this.className,
  });

  factory Assignment.fromMap(String id, Map<String, dynamic> map) {
    return Assignment(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      createdAt: map['createdAt'] ?? '',
      dueDate: map['dueDate'] ?? '',
      maxMarks: map['maxMarks'] ?? 0,
      status: map['status'] ?? 'Pending',
      className: map['className'] ?? '',
    );
  }

  Map<Object, Object?> toMap() {
    return {
      'className': className,
    };
  }
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String className;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final List<Question> questions;
  final bool isActive;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.questions,
    this.isActive = true,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      className: map['className'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      duration: map['duration'] ?? 30,
      questions:
          (map['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'className': className,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'duration': duration,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isActive': isActive,
    };
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctOption;
  final int marks;

  Question({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.marks,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOption: map['correctOption'] ?? 0,
      marks: map['marks'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOption': correctOption,
      'marks': marks,
    };
  }
}

class Result {
  final String id;
  final String studentId;
  final String studentName;
  final String examType;
  final String subject;
  final int marksObtained;
  final int totalMarks;
  final DateTime examDate;
  final String grade;
  final String remarks;

  Result({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examType,
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.examDate,
    required this.grade,
    required this.remarks,
  });

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      examType: map['examType'] ?? '',
      subject: map['subject'] ?? '',
      marksObtained: map['marksObtained'] ?? 0,
      totalMarks: map['totalMarks'] ?? 0,
      examDate: (map['examDate'] as Timestamp).toDate(),
      grade: map['grade'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'examType': examType,
      'subject': subject,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'examDate': Timestamp.fromDate(examDate),
      'grade': grade,
      'remarks': remarks,
    };
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String venue;
  final List<String> targetClasses;
  final bool isPublished;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.targetClasses,
    this.isPublished = false,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      venue: map['venue'] ?? '',
      targetClasses: List<String>.from(map['targetClasses'] ?? []),
      isPublished: map['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'venue': venue,
      'targetClasses': targetClasses,
      'isPublished': isPublished,
    };
  }
}
