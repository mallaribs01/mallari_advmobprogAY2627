import 'package:flutter/material.dart';

/// Controls the application's theme using Provider.
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  /// Returns the current theme mode.
  bool get isDark => _isDark;

  /// Toggles between light and dark mode.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}