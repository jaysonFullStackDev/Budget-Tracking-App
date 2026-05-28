// lib/services/auth_service.dart
// Handles all Firebase Authentication operations.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/input_sanitizer.dart';

class AuthService {
  final FirebaseAuth    _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Auth State Stream ──────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser              => _auth.currentUser;

  // ── Sign Up ────────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Sanitize name input
      final sanitizedName = InputSanitizer.sanitizeWithLimit(name, maxLength: 50);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // Update display name in Firebase Auth
      await user.updateDisplayName(sanitizedName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid:       user.uid,
        name:      sanitizedName,
        email:     email.trim(),
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      // Send email verification
      await user.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw 'Authentication failed: ${e.message}';
    }
  }

  // ── Sign In ────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _getUserModel(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw 'Authentication failed: ${e.message}';
    }
  }

  // ── Email Verification ─────────────────────────────────────────
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async => await _auth.signOut();

  // ── Password Reset ─────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw 'Password reset failed: ${e.message}';
    }
  }

  // ── Get User Profile ───────────────────────────────────────────
  Future<UserModel> _getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found.');
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return await _getUserModel(uid);
  }

  // ── Update Profile ─────────────────────────────────────────────
  Future<void> updateProfile({required String name}) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    final sanitizedName = InputSanitizer.sanitizeWithLimit(name, maxLength: 50);
    await _firestore.collection('users').doc(uid).update({'name': sanitizedName});
    await currentUser!.updateDisplayName(sanitizedName);
  }

  // ── Error Handler ──────────────────────────────────────────────
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':   return 'This email is already registered.';
      case 'invalid-email':           return 'Please enter a valid email address.';
      case 'weak-password':           return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':      return 'Invalid email or password.';
      case 'user-disabled':           return 'This account has been disabled.';
      case 'too-many-requests':       return 'Too many attempts. Please try again later.';
      case 'network-request-failed':  return 'Network error. Check your connection.';
      default:                        return 'Authentication failed. Please try again.';
    }
  }
}
