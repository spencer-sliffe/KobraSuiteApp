import 'package:flutter/material.dart';
import '../../../widgets/homelife/add_child_profile_bottom_sheet.dart';
import '../../../widgets/homelife/add_workout_routine_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddWorkoutRoutineOverlay extends StatelessWidget {
  const AddWorkoutRoutineOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddWorkoutRoutineBottomSheet());
  }
}