import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firebase_collections.dart';
import '../models/quiz.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Assignments
  Future<List<Assignment>> getAssignmentsForClass(String className) async {
    try {
      print('Fetching assignments for class: $className');

      final snapshot = await _firestore
          .collection('assignments')
          .where('className', isEqualTo: className)
          .get();

      print('Found ${snapshot.docs.length} documents');

      final assignments = snapshot.docs.map((doc) {
        print('Processing document: ${doc.id}');
        return Assignment.fromMap(doc.id, doc.data());
      }).toList();

      print('Processed ${assignments.length} assignments');
      return assignments;
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  Future<void> addAssignment(Assignment assignment) async {
    try {
      await _firestore
          .collection('assignments')
          .add(assignment.toMap() as Map<String, dynamic>);
    } catch (e) {
      print('Error adding assignment: $e');
      rethrow;
    }
  }

  Future<void> updateAssignment(Assignment assignment) async {
    try {
      await _firestore
          .collection('assignments')
          .doc(assignment.id)
          .update(assignment.toMap());
    } catch (e) {
      print('Error updating assignment: $e');
      rethrow;
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
    } catch (e) {
      print('Error deleting assignment: $e');
      rethrow;
    }
  }

  // Quizzes
  Future<List<Quiz>> getAvailableQuizzes(String className) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('className', isEqualTo: className)
          .where('endTime', isGreaterThan: DateTime.now())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Quiz.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  Future<void> createQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').add(quiz.toMap());
    } catch (e) {
      print('Error creating quiz: $e');
      rethrow;
    }
  }

  // Results
  Future<List<Result>> getStudentResults(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(RESULTS_COLLECTION)
          .where('studentId', isEqualTo: studentId)
          .orderBy('examDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Result.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching results: $e');
      return [];
    }
  }

  // Events
  Future<List<Event>> getUpcomingEvents(String className) async {
    try {
      final snapshot = await _firestore
          .collection(EVENTS_COLLECTION)
          .where('targetClasses', arrayContains: className)
          .where('date', isGreaterThan: DateTime.now())
          .orderBy('date')
          .get();

      return snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }
}
