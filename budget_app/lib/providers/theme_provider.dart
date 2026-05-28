// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() { _loadTheme(); }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.themeKey);
    if (stored == 'dark')   _themeMode = ThemeMode.dark;
    if (stored == 'light')  _themeMode = ThemeMode.light;
    if (stored == 'system') _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode.name);
  }

  void toggleDarkMode() =>
      setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
}
