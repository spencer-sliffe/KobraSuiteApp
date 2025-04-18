import 'package:flutter/material.dart';
import '../../../widgets/homelife/add_medication_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddMedicationOverlay extends StatelessWidget {
  const AddMedicationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddMedicationBottomSheet());
  }
}