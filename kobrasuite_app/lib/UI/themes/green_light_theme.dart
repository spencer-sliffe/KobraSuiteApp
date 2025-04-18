import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData greenLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // -------------------------------------------------------------------------
  // 1. CORE COLOR SCHEME & BASE COLORS
  // -------------------------------------------------------------------------
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7C3FC5),     // Deep purple: primary for emphasis
    onPrimary: Colors.white,
    secondary: Color(0xFF2FCCA9),   // Vibrant teal: accents and highlights
    onSecondary: Colors.white,
    error: Color(0xFFCF6679),
    onError: Colors.black,
    background: Color(0xFF121212),
    onBackground: Colors.white70,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white70,
  ).copyWith(
    // Tertiary accent: A soft mint to support subtle visual cues.
    tertiary: const Color(0xFFB9E4C9),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),

  // -------------------------------------------------------------------------
  // 2. APP BAR & CUSTOM GRADIENT FOR A MODERN LOOK
  // -------------------------------------------------------------------------
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Set to transparent for gradient
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  // Instead of a standard AppBar background color, wrap your AppBar in a widget that
  // provides a gradient. For example:
  //
  //   appBar: PreferredSize(
  //     preferredSize: const Size.fromHeight(kToolbarHeight),
  //     child: AppBar(
  //       flexibleSpace: Container(
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [Color(0xFF7C3FC5), Color(0xFF2FCCA9)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //         child: Center(child: Text('Your App Title', style: Theme.of(context).appBarTheme.titleTextStyle)),
  //       ),
  //     ),
  //   ),
  //
  // This custom approach lets you incorporate a smooth purple-to-teal gradient behind your app bar.

  // -------------------------------------------------------------------------
  // 3. TYPOGRAPHY & TEXT THEME
  // -------------------------------------------------------------------------
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
    headlineLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF2FCCA9)),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
    bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
    bodyMedium: const TextStyle(fontSize: 14, color: Colors.white60),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),

  // -------------------------------------------------------------------------
  // 4. BUTTON THEMES: Elevated & Text Buttons
  // -------------------------------------------------------------------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7C3FC5),
      foregroundColor: Colors.white,
      iconColor: const Color(0xFF2FCCA9),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF2FCCA9),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

  // -------------------------------------------------------------------------
  // 5. ICON, INPUT & CARD THEMES
  // -------------------------------------------------------------------------
  iconTheme: const IconThemeData(
    color: Color(0xFF2FCCA9),
    size: 24,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    hintStyle: const TextStyle(color: Colors.white60),
    labelStyle: const TextStyle(color: Color(0xFF2FCCA9)),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF2FCCA9), width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shadowColor: Colors.black87,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(10),
  ),

  // -------------------------------------------------------------------------
  // 6. NAVIGATION COMPONENTS
  // -------------------------------------------------------------------------
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: const Color(0xFF121212),
    selectedIconTheme: const IconThemeData(
      color: Color(0xFF7C3FC5),
      size: 28,
    ),
    unselectedIconTheme: const IconThemeData(
      color: Colors.white54,
      size: 24,
    ),
    selectedLabelTextStyle: const TextStyle(
      color: Color(0xFF7C3FC5),
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelTextStyle: const TextStyle(
      color: Colors.white54,
    ),
    indicatorColor: Colors.white10,
    labelType: NavigationRailLabelType.all,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFF7C3FC5),
    unselectedItemColor: Colors.white54,
    showUnselectedLabels: true,
    elevation: 10,
    type: BottomNavigationBarType.fixed,
  ),

  // -------------------------------------------------------------------------
  // 7. FLOATING ACTION BUTTON & SNACK BAR
  // -------------------------------------------------------------------------
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF2FCCA9),
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    contentTextStyle: const TextStyle(color: Colors.white70),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    actionTextColor: const Color(0xFF7C3FC5),
  ),

  // -------------------------------------------------------------------------
  // 8. ADDITIONAL COMPONENTS: DIVIDER, CHIP & SLIDER
  // -------------------------------------------------------------------------
  dividerTheme: const DividerThemeData(
    color: Colors.white30,
    thickness: 1,
    space: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    disabledColor: Colors.grey.shade700,
    selectedColor: const Color(0xFF7C3FC5),
    secondarySelectedColor: const Color(0xFF2FCCA9),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(color: Colors.white),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Colors.white30),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: const Color(0xFF2FCCA9),
    inactiveTrackColor: Colors.white30,
    thumbColor: const Color(0xFF7C3FC5),
    overlayColor: const Color(0x7F7C3FC5), // Semi-transparent overlay
    valueIndicatorColor: const Color(0xFF1E1E1E),
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
    ),
  ),
);