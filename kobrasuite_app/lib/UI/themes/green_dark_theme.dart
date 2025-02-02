import 'package:flutter/material.dart';

final ThemeData greenDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2A9D8F),
    brightness: Brightness.dark,
  ).copyWith(
    secondary: const Color(0xFF264653),
    tertiary: const Color(0xFFE9C46A),
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF2A9D8F),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2A9D8F)),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFF2A9D8F),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF2A9D8F),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF2A9D8F),
    size: 24,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    hintStyle: const TextStyle(color: Colors.white60),
    labelStyle: const TextStyle(color: Color(0xFF2A9D8F)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF264653), width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    elevation: 2,
    shadowColor: Colors.black45,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8),
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: const Color(0xFF121212),
    selectedIconTheme: const IconThemeData(
      color: Color(0xFF2A9D8F),
      size: 28,
    ),
    unselectedIconTheme: const IconThemeData(
      color: Colors.white54,
      size: 24,
    ),
    selectedLabelTextStyle: const TextStyle(
      color: Color(0xFF2A9D8F),
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelTextStyle: const TextStyle(
      color: Colors.white54,
    ),
    indicatorColor: Colors.white.withOpacity(0.1),
    labelType: NavigationRailLabelType.all,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFF2A9D8F),
    unselectedItemColor: Colors.white54,
    showUnselectedLabels: true,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);