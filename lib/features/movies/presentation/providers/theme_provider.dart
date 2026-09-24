import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'user_theme_mode';
  final SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    if (_prefs != null) {
      final savedMode = _prefs.getString(_themeKey);
      if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await _prefs?.setString(_themeKey, 'light');
    } else {
      _themeMode = ThemeMode.dark;
      await _prefs?.setString(_themeKey, 'dark');
    }
    notifyListeners();
  }
}
