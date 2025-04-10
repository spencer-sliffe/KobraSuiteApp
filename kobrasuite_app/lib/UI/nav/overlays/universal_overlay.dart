import 'package:flutter/material.dart';
import 'package:kobrasuite_app/UI/nav/overlays/universal_sync_overlay.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';

import 'finance/add_bank_account_overlay.dart';
import 'finance/add_budget_category_overlay.dart';
import 'finance/add_budget_overlay.dart';
import 'finance/add_portfolio_stock_overlay.dart';
import 'finance/add_stock_portfolio_overlay.dart';
import 'finance/add_transaction_overlay.dart';
import 'homelife/add_calendar_event_overlay.dart';
import 'homelife/add_chore_overlay.dart';
import 'homelife/add_grocery_item_overlay.dart';
import 'school/add_course_overlay.dart';
import 'finance/add_watchlist_stock_overlay.dart';


class UniversalOverlay extends StatelessWidget {
  const UniversalOverlay({Key? key}) : super(key: key);

  Widget? _buildOverlay(NavigationStore navStore) {
    // Define the priority order (only the first active flag returns an overlay)
    if (navStore.searchUniversityActive) {
    } else if (navStore.addCourseActive) {
      return const AddCourseOverlay();
    // } else if (navStore.addProjectActive) {
    //   return const AddProjectOverlay();
    // } else if (navStore.addTeamActive) {
    //   return const AddTeamOverlay();
    // } else if (navStore.addTaskActive) {
    //   return const AddTaskOverlay();
    } else if (navStore.addChoreActive) {
      return const AddChoreOverlay();
    } else if (navStore.addCalendarEventActive) {
      return const AddCalendarEventOverlay();
    // } else if (navStore.addMealActive) {
    //   return const AddMealOverlay();
    } else if (navStore.addGroceryItemActive) {
      return const AddGroceryItemOverlay();
    } else if (navStore.addBankAccountActive) {
      return const AddBankAccountOverlay();
    } else if (navStore.addBudgetActive) {
      return const AddBudgetOverlay();
    } else if (navStore.addCategoryActive) {
      return const AddBudgetCategoryOverlay();
    } else if (navStore.addTransactionActive) {
      return const AddTransactionOverlay();
    } else if (navStore.addStockActive) {
      return const AddPortfolioStockOverlay();
    } else if (navStore.addStockPortfolioActive) {
      return const AddStockPortfolioOverlay();
    } else if (navStore.addWatchlistStockActive) {
      return const AddWatchlistStockOverlay();
    } else if (navStore.syncFinanceOverviewActive) {
      return const UniversalSyncOverlay(
        title: 'Syncing Finance Overview...',
        subtitle: 'Updating your finance overview data.',
      );
    } else if (navStore.syncFinanceAccountsActive) {
      return const UniversalSyncOverlay(
        title: 'Syncing Finance Accounts...',
        subtitle: 'Updating your account details.',
      );
    } else if (navStore.syncFinanceTransactionsActive) {
      return const UniversalSyncOverlay(
        title: 'Syncing Transactions...',
        subtitle: 'Updating transaction data.',
      );
    } else if (navStore.syncStocksActive) {
      return const UniversalSyncOverlay(
        title: 'Syncing Stocks...',
        subtitle: 'Updating your stock positions.',
      );
    } else if (navStore.refreshFinanceNewsActive) {
      return const UniversalSyncOverlay(
        title: 'Refreshing News...',
        subtitle: 'Gathering the latest market updates.',
      );
    // } else if (navStore.aiChatActive) {
    //   return const AIChatOverlay();
    // } else if (navStore.runFinanceAnalysisActive) {
    //   return const RunFinanceAnalysisOverlay();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final navStore = context.watch<NavigationStore>();
    final overlay = _buildOverlay(navStore);
    return overlay ?? const SizedBox.shrink();
  }
}