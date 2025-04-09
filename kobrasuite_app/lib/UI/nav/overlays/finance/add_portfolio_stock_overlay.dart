import 'package:flutter/material.dart';
import '../universal_bottom_overlay.dart'; // Adjust the import path as needed.
import '../../../widgets/finance/add_portfolio_stock_bottom_sheet.dart';

class AddPortfolioStockOverlay extends StatelessWidget {
  const AddPortfolioStockOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the portfolio stock bottom sheet with UniversalBottomOverlay
    // so it fills the available bottom space.
    return UniversalBottomOverlay(child: const AddPortfolioStockBottomSheet());
  }
}