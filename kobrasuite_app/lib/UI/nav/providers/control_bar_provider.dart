import 'package:flutter/material.dart';

class ControlBarButtonModel {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ControlBarButtonModel({required this.icon, required this.label, required this.onPressed});
}

class ControlBarProvider extends ChangeNotifier {
  final List<ControlBarButtonModel> _buttons = [];

  List<ControlBarButtonModel> get buttons => List.unmodifiable(_buttons);

  void addButton(ControlBarButtonModel button) {
    _buttons.add(button);
    notifyListeners();
  }

  void removeButton(ControlBarButtonModel button) {
    _buttons.remove(button);
    notifyListeners();
  }

  void clearButtons() {
    _buttons.clear();
    notifyListeners();
  }
}