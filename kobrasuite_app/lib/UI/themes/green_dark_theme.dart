import 'package:flutter/material.dart';

final ThemeData greenDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2A9D8F), // A slightly subdued teal for dark mode
    brightness: Brightness.dark,
  ).copyWith(
    secondary: const Color(0xFF264653), // Deep complementary accent
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
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white70,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Colors.white60,
      fontSize: 14,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF2A9D8F),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
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
    indicatorColor: const Color(0xFF264653).withOpacity(0.3),
    labelType: NavigationRailLabelType.all,
  ),
);