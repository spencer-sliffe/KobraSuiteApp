import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust the import path as needed.
import '../../../widgets/finance/add_bank_account_bottom_sheet.dart';

class AddBankAccountOverlay extends StatelessWidget {
  const AddBankAccountOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instead of hard-coding a height, we wrap the bottom sheet with UniversalBottomOverlay
    // so it fills the available space.
    return UniversalBottomOverlay(child: const AddBankAccountBottomSheet());
  }
}