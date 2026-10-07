import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- AUTHENTICATION METHODS ---

  Future<String?> signUp({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'An error occurred during registration.';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'An error occurred during sign in.';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> resetPassword({required String email}) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'An error occurred resetting password.';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- FIRESTORE NOTES CRUD METHODS ---

  // Get User's Notes Stream
  Stream<QuerySnapshot> getNotesStream() {
    final uid = currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add Note
  Future<String?> addNote({required String title, required String content}) async {
    final uid = currentUser?.uid;
    if (uid == null) return 'User not logged in';

    try {
      await _db.collection('users').doc(uid).collection('notes').add({
        'title': title.trim(),
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Update Note
  Future<String?> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return 'User not logged in';

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .update({
        'title': title.trim(),
        'content': content.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete Note
  Future<String?> deleteNote(String noteId) async {
    final uid = currentUser?.uid;
    if (uid == null) return 'User not logged in';

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
