import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust the import path as needed.
import '../../../widgets/school/add_course_bottom_sheet.dart';

class AddCourseOverlay extends StatelessWidget {
  const AddCourseOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instead of hard-coding a percentage of height, we wrap the bottom sheet
    // with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddCourseBottomSheet());
  }
}