class SubjectResult {
  final String subject;
  final int marksObtained;
  final int totalMarks;
  final String grade;
  final String remarks;

  SubjectResult({
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.grade,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'grade': grade,
      'remarks': remarks,
    };
  }

  factory SubjectResult.fromMap(Map<String, dynamic> map) {
    return SubjectResult(
      subject: map['subject'],
      marksObtained: map['marksObtained'],
      totalMarks: map['totalMarks'],
      grade: map['grade'],
      remarks: map['remarks'],
    );
  }
}

class Result {
  final String? id;
  final String studentId;
  final String studentName;
  final String className;
  final String examType; // Mid-term, Final, etc.
  final String semester;
  final List<SubjectResult> subjects;
  final double percentage;
  final String overallGrade;
  final int rank;
  final DateTime examDate;
  final DateTime declaredDate;
  final bool isPublished;

  Result({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.examType,
    required this.semester,
    required this.subjects,
    required this.percentage,
    required this.overallGrade,
    required this.rank,
    required this.examDate,
    required this.declaredDate,
    this.isPublished = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'examType': examType,
      'semester': semester,
      'subjects': subjects.map((s) => s.toMap()).toList(),
      'percentage': percentage,
      'overallGrade': overallGrade,
      'rank': rank,
      'examDate': examDate.toIso8601String(),
      'declaredDate': declaredDate.toIso8601String(),
      'isPublished': isPublished,
    };
  }

  factory Result.fromMap(String id, Map<String, dynamic> map) {
    return Result(
      id: id,
      studentId: map['studentId'],
      studentName: map['studentName'],
      className: map['className'],
      examType: map['examType'],
      semester: map['semester'],
      subjects: (map['subjects'] as List)
          .map((s) => SubjectResult.fromMap(s))
          .toList(),
      percentage: map['percentage'],
      overallGrade: map['overallGrade'],
      rank: map['rank'],
      examDate: DateTime.parse(map['examDate']),
      declaredDate: DateTime.parse(map['declaredDate']),
      isPublished: map['isPublished'] ?? false,
    );
  }
}
