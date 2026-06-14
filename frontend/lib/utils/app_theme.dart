import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A2E4A);
  static const Color primaryLight = Color(0xFF2C4A6E);
  static const Color primaryDark = Color(0xFF0F1D30);

  static const Color accent = Color(0xFFE8C96A);
  static const Color accentLight = Color(0xFFF2DC8E);
  static const Color accentDark = Color(0xFF9A7B2D);

  static const Color background = Color(0xFFF5F2ED);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF0ECE4);

  static const Color carreraOficial = Color(0xFFD4A843);
  static const Color carreraOficialBg = Color(0x20D4A843);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Colors.white;

  static const Color border = Color(0xFFE0DDD6);
  static const Color divider = Color(0xFFE8E4DC);

  static const Color textOnPrimaryMuted = Color(0xFF8A9BB5);
  static const Color destructive = Color(0xFFC53030);

  static const Color successText = Color(0xFF6B5317);
  static const Color successBg = Color(0xFFF7F2E6);
  static const Color successBorder = Color(0xFFCDBF8E);

  static const Color errorText = Color(0xFF9B4430);
  static const Color errorBg = Color(0xFFFAF0EE);
  static const Color errorBorder = Color(0xFFDEB8AB);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textOnPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textOnPrimaryMuted,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: AppColors.accent,
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textOnPrimaryMuted,
    ),
  );
}

class AppInputDecoration {
  static InputDecoration build({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(120)),
      prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final textColor = isError ? AppColors.errorText : AppColors.successText;
    final bgColor = isError ? AppColors.errorBg : AppColors.successBg;
    final borderColor = isError ? AppColors.errorBorder : AppColors.successBorder;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: '✕',
          textColor: textColor,
          onPressed: () {},
        ),
      ),
    );
  }
}
