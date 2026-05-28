// lib/utils/session_manager.dart
// Manages user session timeout for security.

import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager with WidgetsBindingObserver {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const Duration sessionTimeout = Duration(minutes: 15);

  Timer? _timer;
  VoidCallback? _onSessionExpired;
  bool _isActive = false;

  void initialize({required VoidCallback onSessionExpired}) {
    _onSessionExpired = onSessionExpired;
    _isActive = true;
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void dispose() {
    _timer?.cancel();
    _isActive = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  void recordActivity() {
    if (_isActive) _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(sessionTimeout, _expireSession);
  }

  void _expireSession() {
    if (_isActive) {
      _onSessionExpired?.call();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    }
  }
}
