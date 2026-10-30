import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Global theme notifier
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

  static bool get isDarkMode => isDarkModeNotifier.value;

  static Future<void> initTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('app_theme');
      if (savedTheme != null) {
        isDarkModeNotifier.value = (savedTheme.toLowerCase() != 'light');
      }
    } catch (_) {}
  }

  static void setTheme(String theme) {
    final isDark = theme.toLowerCase() != 'light';
    setDarkMode(isDark);
  }

  static void setDarkMode(bool isDark) {
    if (isDarkModeNotifier.value != isDark) {
      isDarkModeNotifier.value = isDark;
    }
  }

  // ==========================================
  // Premium Midnight Blue + Electric Cyan Theme
  // ==========================================
  // 70% Midnight Black background: #080D18
  // 20% Dark Navy cards: #111C2E
  // 10% Electric Blue & Cyan accents: #287BFF & #20D9E8
  static Color get backgroundColor => isDarkMode ? const Color(0xFF080D18) : const Color(0xFFF4F7FC);
  static Color get cardColor => isDarkMode ? const Color(0xFF111C2E) : const Color(0xFFFFFFFF);
  static Color get secondaryCardColor => isDarkMode ? const Color(0xFF192941) : const Color(0xFFE8EEF8);
  static Color get primaryColor => const Color(0xFF287BFF); // Electric Blue
  static Color get accentColor => const Color(0xFF20D9E8); // Electric Cyan
  static Color get cyanColor => const Color(0xFF20D9E8); // Cyan Accent
  static Color get electricBlue => const Color(0xFF287BFF); // Electric Blue Accent
  static Color get primaryText => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF0A1120);
  static Color get secondaryText => isDarkMode ? const Color(0xFFAAB6C8) : const Color(0xFF64748B);
  static Color get borderColor => isDarkMode ? const Color(0xFF293B54) : const Color(0xFFD6E0EE);

  // Status and Accent Colors (Exact User Specifications)
  static Color get successColor => const Color(0xFF22C55E); // Confirmed / Success Green
  static Color get warningColor => const Color(0xFFF59E0B); // Pending Orange / Amber
  static Color get errorColor => const Color(0xFFEF4444);   // Cancelled / Danger Red
  static Color get infoColor => const Color(0xFF3B82F6);    // Information Blue
  static Color get coralRed => const Color(0xFFEF4444);     // Destructive / Logout / Danger
  static Color get heartColor => const Color(0xFFFF3366);   // Favorite Heart Pink/Red
}
