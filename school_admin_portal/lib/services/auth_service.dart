import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      }
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  Future<void> _loadUserData() async {
    if (_user != null) {
      final doc = await _firestore.collection('teachers').doc(_user!.uid).get();
      _userData = doc.data();
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userData = null;
  }
}
