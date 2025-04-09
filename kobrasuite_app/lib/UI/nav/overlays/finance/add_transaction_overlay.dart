import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust the import path as needed.
import '../../../widgets/finance/add_transaction_bottom_sheet.dart';

class AddTransactionOverlay extends StatelessWidget {
  const AddTransactionOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the transaction bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const AddTransactionBottomSheet());
  }
}