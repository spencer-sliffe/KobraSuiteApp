import 'package:flutter/material.dart';

class ControlBarButtonModel {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ControlBarButtonModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ControlBarButtonModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ControlBarProvider extends ChangeNotifier {
  final List<ControlBarButtonModel> _persistentButtons = [];
  final List<ControlBarButtonModel> _ephemeralButtons = [];

  List<ControlBarButtonModel> get allButtons =>
      List.unmodifiable([..._persistentButtons, ..._ephemeralButtons]);

  void addPersistentButton(ControlBarButtonModel button) {
    if (!_persistentButtons.contains(button)) {
      _persistentButtons.add(button);
      notifyListeners();
    }
  }

  void removePersistentButton(ControlBarButtonModel button) {
    final int initialLength = _persistentButtons.length;
    _persistentButtons.removeWhere((b) => b.id == button.id);
    if (_persistentButtons.length != initialLength) {
      notifyListeners();
    }
  }

  void clearPersistentButtons() {
    if (_persistentButtons.isNotEmpty) {
      _persistentButtons.clear();
      notifyListeners();
    }
  }

  void addEphemeralButton(ControlBarButtonModel button) {
    if (!_ephemeralButtons.contains(button)) {
      _ephemeralButtons.add(button);
      notifyListeners();
    }
  }

  void removeEphemeralButton(ControlBarButtonModel button) {
    final int initialLength = _ephemeralButtons.length;
    _ephemeralButtons.removeWhere((b) => b.id == button.id);
    if (_ephemeralButtons.length != initialLength) {
      notifyListeners();
    }
  }

  void clearEphemeralButtons() {
    if (_ephemeralButtons.isNotEmpty) {
      _ephemeralButtons.clear();
      notifyListeners();
    }
  }
}