import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';

import '../../widgets/ai/draggable_chat_overlay.dart';
import 'finance/add_bank_account_overlay.dart';
import 'finance/add_budget_category_overlay.dart';
import 'finance/add_budget_overlay.dart';
import 'finance/add_portfolio_stock_overlay.dart';
import 'finance/add_stock_portfolio_overlay.dart';
import 'finance/add_transaction_overlay.dart';
import 'homelife/add_calendar_event_overlay.dart';
import 'homelife/add_child_profile_overlay.dart';
import 'homelife/add_chore_overlay.dart';
import 'homelife/add_grocery_item_overlay.dart';
import 'homelife/add_grocerylist_overlay.dart';
import 'homelife/add_meal_overlay.dart';
import 'homelife/add_medical_appointment.dart';
import 'homelife/add_medication_overlay.dart';
import 'homelife/add_pet_overlay.dart';
import 'homelife/add_workout_routine_overlay.dart';
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
    } else if (navStore.addPetActive) {
      return const AddPetOverlay();
    } else if (navStore.addMedicationActive) {
      return const AddMedicationOverlay();
    } else if (navStore.addMedicalAppointmentActive) {
      return const AddMedicalAppointmentOverlay();
    } else if (navStore.addChildProfileActive) {
      return const AddChildProfileOverlay();
    } else if (navStore.addChoreActive) {
      return const AddChoreOverlay();
    } else if (navStore.addCalendarEventActive) {
      return const AddCalendarEventOverlay();
    } else if (navStore.addMealActive) {
      return const AddMealOverlay();
    } else if (navStore.addGroceryItemActive) {
      return const AddGroceryItemOverlay();
    } else if (navStore.addGroceryListActive) {
      return const AddGroceryListOverlay();
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
    } else if (navStore.addWorkoutRoutineActive) {
      return const AddWorkoutRoutineOverlay();
    } else if (navStore.aiChatActive) {
      return const DraggableChatOverlay();
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