// config.dart
// lib/config.dart

import 'package:flutter/foundation.dart';

/// Simple class that decides which base URL to use, local vs. production.
class Config {
  /// Toggle this flag to switch between local dev and production.
  static String get baseUrl {
    if (kDebugMode) {
      return 'http://0.0.0.0:8000';
    } else {
      return 'https://kobrasuite-backend.azurewebsites.net';
    }
  }
}