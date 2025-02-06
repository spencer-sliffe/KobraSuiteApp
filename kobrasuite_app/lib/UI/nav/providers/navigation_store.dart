import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  Module _activeModule = Module.Finances;
  bool _isHQActive = false;
  HQView _hqView = HQView.Dashboard;

  Module get activeModule => _activeModule;
  bool get isHQActive => _isHQActive;
  HQView get hqView => _hqView;

  void setActiveModule(Module module) {
    _activeModule = module;
    notifyListeners();
  }

  void toggleHQ() {
    _isHQActive = !_isHQActive;
    notifyListeners();
  }

  void setHQActive(bool active) {
    if (_isHQActive != active) {
      _isHQActive = active;
      notifyListeners();
    }
  }

  void switchHQView(HQView view) {
    if (_hqView != view) {
      _hqView = view;
      notifyListeners();
    }
  }
}