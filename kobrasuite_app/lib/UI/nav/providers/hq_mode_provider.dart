import 'package:flutter/material.dart';
import 'navigation_store.dart';

class HQModeProvider extends ChangeNotifier {
  final NavigationStore navigationStore;

  HQModeProvider(this.navigationStore) {
    navigationStore.addListener(notifyListeners);
  }

  bool get HQActive => navigationStore.hqActive;
  HQView get currentHQView => navigationStore.hqView;

  void toggleHQMode() {
    navigationStore.toggleHQ();
  }

  void setHQView(HQView view) {
    navigationStore.switchHQView(view);
  }
}