// lib/providers/auth_provider.dart
// Manages authentication state throughout the app.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/session_manager.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus  _status   = AuthStatus.initial;
  UserModel?  _user;
  String?     _errorMessage;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading    => _status == AuthStatus.loading;
  String?    get userId       => _user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
  bool       get isEmailVerified => _authService.isEmailVerified;

  AuthProvider() {
    // Listen to Firebase auth state changes for session persistence
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user   = null;
      } else {
        _status = AuthStatus.authenticated;
        _user   ??= await _authService.getUserProfile();
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _user   = null;
    }
    notifyListeners();
  }

  // ── Sign Up ────────────────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user   = await _authService.signUp(name: name, email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign In ────────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      _user   = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    SessionManager().dispose();
    await _authService.signOut();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Reset Password ─────────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    _setLoading();
    try {
      await _authService.resetPassword(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Update Profile ─────────────────────────────────────────────
  Future<bool> updateProfile({required String name}) async {
    try {
      await _authService.updateProfile(name: name);
      _user = _user?.copyWith(name: name);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Email Verification ─────────────────────────────────────────
  Future<bool> checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      return _authService.isEmailVerified;
    } catch (_) {
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    await _authService.sendVerificationEmail();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = msg;
    notifyListeners();
  }
}
