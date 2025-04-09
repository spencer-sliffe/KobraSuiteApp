import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust path as needed.
import '../../../widgets/finance/add_budget_bottom_sheet.dart';

class AddBudgetOverlay extends StatelessWidget {
  const AddBudgetOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the budget bottom sheet in the universal overlay,
    // so it fills the available bottom space.
    return UniversalBottomOverlay(child: const AddBudgetBottomSheet());
  }
}