class QuizResult {
  final String id;
  final String quizId;
  final String studentId;
  final String studentName;
  final Map<String, String> answers; // questionId -> student's answer
  final int score;
  final DateTime submittedAt;
  final Duration timeTaken;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.submittedAt,
    required this.timeTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers,
      'score': score,
      'submittedAt': submittedAt.toIso8601String(),
      'timeTaken': timeTaken.inSeconds,
    };
  }

  factory QuizResult.fromMap(String id, Map<String, dynamic> map) {
    return QuizResult(
      id: id,
      quizId: map['quizId'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      answers: Map<String, String>.from(map['answers']),
      score: map['score'],
      submittedAt: DateTime.parse(map['submittedAt']),
      timeTaken: Duration(seconds: map['timeTaken']),
    );
  }
}
