// lib/UI/nav/providers/navigation_store.dart
import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  Module _module = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;
  int _activeFinancesTabIndex = 0;
  int _activeSchoolTabIndex = 0;
  int _activeWorkTabIndex = 0;
  int _activeHomeLifeTabIndex = 0;

  Module get activeModule => _module;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;
  int get activeFinancesTabIndex => _activeFinancesTabIndex;
  int get activeWorkTabIndex => _activeWorkTabIndex;
  int get activeSchoolTabIndex => _activeSchoolTabIndex;
  int get activeHomeLifeTabIndex => _activeHomeLifeTabIndex;


  void setActiveModule(Module module) {
    _module = module;
    notifyListeners();
  }

  void setActiveFinancesTabIndex(int index) {
    if (_activeFinancesTabIndex != index) {
      _activeFinancesTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveSchoolTabIndex(int index) {
    if (_activeSchoolTabIndex != index) {
      _activeSchoolTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveHomeLifeTabIndex(int index) {
    if (_activeHomeLifeTabIndex != index) {
      _activeHomeLifeTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveWorkTabIndex(int index) {
    if (_activeWorkTabIndex != index) {
      _activeWorkTabIndex = index;
      notifyListeners();
    }
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