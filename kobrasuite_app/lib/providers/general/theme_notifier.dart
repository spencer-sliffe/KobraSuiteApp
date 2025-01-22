// lib/providers/general/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/general/app_theme.dart';

class ThemeNotifier with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.LightGreen;

  AppTheme get currentTheme => _currentTheme;

  ThemeNotifier() {
    _loadTheme();
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
    _saveTheme(theme);
  }

  void toggleTheme() {
    if (_currentTheme == AppTheme.DarkGreen) {
      setTheme(AppTheme.LightGreen);
    } else {
      setTheme(AppTheme.DarkGreen);
    }
  }

  Future<void> _saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.toString());
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('app_theme');
    if (themeString != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => AppTheme.LightGreen,
      );
      notifyListeners();
    }
  }
}