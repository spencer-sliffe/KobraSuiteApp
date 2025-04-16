import 'package:flutter/material.dart';
import '../../../widgets/homelife/add_meal_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddMealOverlay extends StatelessWidget {
  const AddMealOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddMealBottomSheet());
  }
}