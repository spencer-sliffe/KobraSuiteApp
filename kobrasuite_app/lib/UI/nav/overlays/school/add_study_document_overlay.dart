import 'package:flutter/material.dart';
import '../../../widgets/school/add_study_document_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';

class AddStudyDocumentOverlay extends StatelessWidget {
  const AddStudyDocumentOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the study document bottom sheet in UniversalBottomOverlay,
    // ensuring it fills the available bottom space.
    return UniversalBottomOverlay(child: const AddStudyDocumentBottomSheet());
  }
}