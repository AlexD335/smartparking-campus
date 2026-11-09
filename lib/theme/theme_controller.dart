import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static const String _themeKey = 'dark_mode';

  static Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final isDark = preferences.getBool(_themeKey) ?? false;

    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool enabled) async {
    themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, enabled);
  }
}
