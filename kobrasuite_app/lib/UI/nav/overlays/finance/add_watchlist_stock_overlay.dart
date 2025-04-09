import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust the import path as needed.
import '../../../widgets/finance/add_watchlist_stock_bottom_sheet.dart';

class AddWatchlistStockOverlay extends StatelessWidget {
  const AddWatchlistStockOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet form in UniversalBottomOverlay so it fills
    // the available space at the bottom.
    return UniversalBottomOverlay(child: const AddWatchlistStockBottomSheet());
  }
}