// lib/UI/nav/providers/control_bar_provider.dart
import 'package:flutter/material.dart';

class ControlBarButtonModel {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ControlBarButtonModel({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class ControlBarProvider extends ChangeNotifier {
  final List<ControlBarButtonModel> _persistentButtons = [];
  final List<ControlBarButtonModel> _ephemeralButtons = [];

  List<ControlBarButtonModel> get allButtons =>
      List.unmodifiable([..._persistentButtons, ..._ephemeralButtons]);

  void addPersistentButton(ControlBarButtonModel button) {
    _persistentButtons.add(button);
    notifyListeners();
  }

  void removePersistentButton(ControlBarButtonModel button) {
    _persistentButtons.remove(button);
    notifyListeners();
  }

  void clearPersistentButtons() {
    _persistentButtons.clear();
    notifyListeners();
  }

  void addEphemeralButton(ControlBarButtonModel button) {
    _ephemeralButtons.add(button);
    notifyListeners();
  }

  void removeEphemeralButton(ControlBarButtonModel button) {
    _ephemeralButtons.remove(button);
    notifyListeners();
  }

  void clearEphemeralButtons() {
    _ephemeralButtons.clear();
    notifyListeners();
  }
}