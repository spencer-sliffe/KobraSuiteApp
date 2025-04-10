import 'package:flutter/material.dart';
import '../../../widgets/homelife/add_chore_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddChoreOverlay extends StatelessWidget {
  const AddChoreOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the chore bottom sheet with UniversalBottomOverlay so it fills the available bottom space.
    return UniversalBottomOverlay(child: const AddChoreBottomSheet());
  }
}