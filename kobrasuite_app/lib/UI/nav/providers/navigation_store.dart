import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  List<Module> _moduleOrder = Module.values.toList();
  Module _activeModule = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;
  int _activeFinancesTabIndex = 0;
  int _activeSchoolTabIndex = 0;
  int _activeWorkTabIndex = 0;
  int _activeHomeLifeTabIndex = 0;

  List<Module> get moduleOrder => _moduleOrder;
  Module get activeModule => _activeModule;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;
  int get activeFinancesTabIndex => _activeFinancesTabIndex;
  int get activeWorkTabIndex => _activeWorkTabIndex;
  int get activeSchoolTabIndex => _activeSchoolTabIndex;
  int get activeHomeLifeTabIndex => _activeHomeLifeTabIndex;


  void setModuleOrder(List<Module> newOrder) {
    _moduleOrder = newOrder;
    notifyListeners();
  }

  void setActiveModule(Module module) {
    _activeModule = module;
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