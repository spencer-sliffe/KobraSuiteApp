import 'package:flutter/material.dart';
import '../../../widgets/finance/add_stock_portfolio_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class AddStockPortfolioOverlay extends StatelessWidget {
  const AddStockPortfolioOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available area.
    return UniversalBottomOverlay(child: const AddStockPortfolioBottomSheet());
  }
}