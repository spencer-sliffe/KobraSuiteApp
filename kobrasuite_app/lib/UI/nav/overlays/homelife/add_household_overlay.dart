import 'package:flutter/material.dart';
import '../../../widgets/homelife/add_household_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddHouseholdOverlay extends StatelessWidget {
  const AddHouseholdOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddHouseholdBottomSheet());
  }
}