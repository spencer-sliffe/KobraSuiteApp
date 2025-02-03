// File: lib/UI/themes/ultra_modern_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UltraModernThemeExtension extends ThemeExtension<UltraModernThemeExtension> {
  final LinearGradient? backgroundGradient;
  final LinearGradient? buttonGradient;

  const UltraModernThemeExtension({
    required this.backgroundGradient,
    required this.buttonGradient,
  });

  @override
  UltraModernThemeExtension copyWith({
    LinearGradient? backgroundGradient,
    LinearGradient? buttonGradient,
  }) {
    return UltraModernThemeExtension(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      buttonGradient: buttonGradient ?? this.buttonGradient,
    );
  }

  @override
  UltraModernThemeExtension lerp(ThemeExtension<UltraModernThemeExtension>? other, double t) {
    if (other is! UltraModernThemeExtension) return this;
    return UltraModernThemeExtension(
      backgroundGradient: LinearGradient.lerp(backgroundGradient, other.backgroundGradient, t),
      buttonGradient: LinearGradient.lerp(buttonGradient, other.buttonGradient, t),
    );
  }
}

final ThemeData ultraModernTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0A84FF),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF0A84FF),
    secondary: const Color(0xFF5AC8FA),
    tertiary: const Color(0xFF34C759),
    error: Colors.redAccent,
    background: const Color(0xFFF2F2F7),
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF2F2F7),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF0A84FF),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 4,
    titleTextStyle: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: GoogleFonts.robotoTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87),
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0A84FF)),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A84FF)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0A84FF),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 6,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF0A84FF),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: Colors.black38),
    labelStyle: const TextStyle(color: Color(0xFF0A84FF)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black26),
      borderRadius: BorderRadius.circular(24),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
      borderRadius: BorderRadius.circular(24),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(24),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 8,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    margin: const EdgeInsets.all(12),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFE0F7FF),
    labelStyle: const TextStyle(color: Colors.black87),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    secondarySelectedColor: const Color(0xFF0A84FF),
    selectedColor: const Color(0xFF0A84FF).withOpacity(0.8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: const Color(0xFFF2F2F7),
    selectedIconTheme: const IconThemeData(
      color: Color(0xFF0A84FF),
      size: 28,
    ),
    unselectedIconTheme: const IconThemeData(
      color: Colors.black45,
      size: 24,
    ),
    selectedLabelTextStyle: const TextStyle(
      color: Color(0xFF0A84FF),
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelTextStyle: const TextStyle(
      color: Colors.black45,
    ),
    indicatorColor: const Color(0xFF0A84FF).withOpacity(0.1),
    labelType: NavigationRailLabelType.all,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF0A84FF),
    unselectedItemColor: Colors.black54,
    showUnselectedLabels: true,
    elevation: 10,
    type: BottomNavigationBarType.fixed,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF0A84FF),
    contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
    textStyle: const TextStyle(color: Colors.black87),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  extensions: <ThemeExtension<dynamic>>[
    const UltraModernThemeExtension(
      backgroundGradient: LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      buttonGradient: LinearGradient(
        colors: [Color(0xFF34C759), Color(0xFF0A84FF)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
  ],
);