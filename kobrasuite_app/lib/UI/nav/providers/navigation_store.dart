/// lib/UI/nav/providers/navigation_store.dart

import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  Module _module = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;

  Module get activeModule => _module;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;

  void setActiveModule(Module module) {
    _module = module;
    notifyListeners();
  }

  void toggleHQ() {
    _hqActive = !_hqActive;
    notifyListeners();
  }

  void setHQActive(bool active) {
    if (_hqActive != active) {
      _hqActive = active;
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