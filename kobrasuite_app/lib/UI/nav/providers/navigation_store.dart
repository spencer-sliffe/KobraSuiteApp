import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  List<Module> _moduleOrder = Module.values.toList();
  Module _activeModule = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;

  List<Module> get moduleOrder => _moduleOrder;
  Module get activeModule => _activeModule;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;

  void setModuleOrder(List<Module> newOrder) {
    _moduleOrder = newOrder;
    notifyListeners();
  }

  void setActiveModule(Module module) {
    _activeModule = module;
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