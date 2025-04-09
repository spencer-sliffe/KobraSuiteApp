import 'package:flutter/material.dart';
import '../../../widgets/school/add_assignment_bottom_sheeet.dart';
import '../universal_bottom_overlay.dart';

class AddAssignmentOverlay extends StatelessWidget {
  const AddAssignmentOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the assignment bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddAssignmentBottomSheet());
  }
}