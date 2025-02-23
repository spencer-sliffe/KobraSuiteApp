import 'package:flutter/material.dart';
import 'navigation_store.dart';

class HQModeProvider extends ChangeNotifier {
  final NavigationStore navigationStore;

  // You can also keep thresholds in one place:
  final double pinchInThreshold = 0.85;
  final double pinchOutThreshold = 1.15;

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

  void updateHQStatus(double scale) {
    if (scale < pinchInThreshold && !HQActive) {
      navigationStore.setHQActive(true);
    } else if (scale > pinchOutThreshold && HQActive) {
      navigationStore.setHQActive(false);
    }
  }
}