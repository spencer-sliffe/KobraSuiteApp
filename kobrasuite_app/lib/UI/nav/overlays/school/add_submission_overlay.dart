import 'package:flutter/material.dart';
import '../../../widgets/school/add_submission_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';

class AddSubmissionOverlay extends StatelessWidget {
  const AddSubmissionOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the submission bottom sheet with UniversalBottomOverlay.
    return UniversalBottomOverlay(child: const AddSubmissionBottomSheet());
  }
}