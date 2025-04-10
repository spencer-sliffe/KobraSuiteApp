import 'package:flutter/material.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  //Module Control
  List<Module> _moduleOrder = Module.values.toList();
  Module _activeModule = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;

  //Tab Control
  int _activeFinancesTabIndex = 0;
  int _activeSchoolTabIndex = 0;
  int _activeWorkTabIndex = 0;
  int _activeHomeLifeTabIndex = 0;

  //Control Bar Button Control
  bool _searchUniversityActive = false;
  bool _addCourseActive = false;
  bool _addProjectActive = false;
  bool _addTeamActive = false;
  bool _addTaskActive = false;
  bool _addChoreActive = false;
  bool _addCalendarEventActive = false;
  bool _addMealActive = false;
  bool _addBankAccountActive = false;
  bool _addBudgetActive = false;
  bool _addCategoryActive = false;
  bool _addTransactionActive = false;
  bool _addStockActive = false;
  bool _addWatchlistStockActive = false;
  bool _syncFinanceOverviewActive = false;
  bool _syncFinanceAccountsActive = false;
  bool _syncFinanceTransactionsActive = false;
  bool _syncStocksActive = false;
  bool _refreshFinanceNewsActive = false;
  bool _aiChatActive = false;
  bool _runFinanceAnalysisActive = false;
  bool _addStockPortfolioActive = false;
  bool _addTopicStudyDocumentActive = false;
  bool _addCourseTopicActive = false;
  bool _addAssignmentSubmissionActive = false;
  bool _addPetActive = false;
  bool _addMedicationActive = false;
  bool _addMedicalAppointmentActive = false;
  bool _sendHouseholdInviteActive = false;
  bool _addWorkoutRoutineActive = false;
  bool _addChildProfileActive = false;
  bool _addGroceryListActive = false;
  bool _addGroceryItemActive = false;


  List<Module> get moduleOrder => _moduleOrder;
  Module get activeModule => _activeModule;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;
  int get activeFinancesTabIndex => _activeFinancesTabIndex;
  int get activeWorkTabIndex => _activeWorkTabIndex;
  int get activeSchoolTabIndex => _activeSchoolTabIndex;
  int get activeHomeLifeTabIndex => _activeHomeLifeTabIndex;
  bool get searchUniversityActive => _searchUniversityActive;
  bool get addCourseActive => _addCourseActive;
  bool get addProjectActive => _addProjectActive;
  bool get addTeamActive => _addTeamActive;
  bool get addTaskActive => _addTaskActive;
  bool get addChoreActive => _addChoreActive;
  bool get addCalendarEventActive => _addCalendarEventActive;
  bool get addMealActive => _addMealActive;
  bool get addBankAccountActive => _addBankAccountActive;
  bool get addBudgetActive => _addBudgetActive;
  bool get addCategoryActive => _addCategoryActive;
  bool get addTransactionActive => _addTransactionActive;
  bool get addStockActive => _addStockActive;
  bool get addWatchlistStockActive => _addWatchlistStockActive;
  bool get syncFinanceOverviewActive => _syncFinanceOverviewActive;
  bool get syncFinanceAccountsActive => _syncFinanceAccountsActive;
  bool get syncFinanceTransactionsActive => _syncFinanceTransactionsActive;
  bool get syncStocksActive => _syncStocksActive;
  bool get refreshFinanceNewsActive => _refreshFinanceNewsActive;
  bool get aiChatActive => _aiChatActive;
  bool get runFinanceAnalysisActive => _runFinanceAnalysisActive;
  bool get addStockPortfolioActive => _addStockPortfolioActive;
  bool get addTopicStudyDocumentActive => _addTopicStudyDocumentActive;
  bool get addCourseTopicActive => _addCourseTopicActive;
  bool get addAssignmentSubmissionActive => _addAssignmentSubmissionActive;
  bool get addPetActive => _addPetActive;
  bool get addMedicationActive => _addMedicationActive;
  bool get addMedicalAppointmentActive => _addMedicalAppointmentActive;
  bool get sendHouseholdInviteActive => _sendHouseholdInviteActive;
  bool get addWorkoutRoutineActive => _addWorkoutRoutineActive;
  bool get addChildProfileActive => _addChildProfileActive;
  bool get addGroceryListActive => _addGroceryListActive;
  bool get addGroceryItemActive => _addGroceryItemActive;

  void setModuleOrder(List<Module> newOrder) {
    _moduleOrder = newOrder;
    notifyListeners();
  }

  void setActiveModule(Module module) {
    _activeModule = module;
    notifyListeners();
  }

  void setActiveFinancesTabIndex(int index) {
    if (_activeFinancesTabIndex != index) {
      _activeFinancesTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveSchoolTabIndex(int index) {
    if (_activeSchoolTabIndex != index) {
      _activeSchoolTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveHomeLifeTabIndex(int index) {
    if (_activeHomeLifeTabIndex != index) {
      _activeHomeLifeTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveWorkTabIndex(int index) {
    if (_activeWorkTabIndex != index) {
      _activeWorkTabIndex = index;
      notifyListeners();
    }
  }

  void toggleHQ() {
    _hqActive = !_hqActive;
    notifyListeners();
  }

  void setSearchUniversityActive() {
    _searchUniversityActive = !_searchUniversityActive;
    notifyListeners();
  }

  void setAddCourseActive() {
    _addCourseActive = !_addCourseActive;
    notifyListeners();
  }

  void setAddProjectActive() {
    _addProjectActive = !_addProjectActive;
    notifyListeners();
  }

  void setAddTeamActive() {
    _addTeamActive = !_addTeamActive;
    notifyListeners();
  }

  void setAddTaskActive() {
    _addTaskActive = !_addTaskActive;
    notifyListeners();
  }

  void setAddChoreActive() {
    _addChoreActive = !_addChoreActive;
    notifyListeners();
  }

  void setAddCalendarEventActive() {
    _addCalendarEventActive = !_addCalendarEventActive;
    notifyListeners();
  }

  void setAddMealActive() {
    _addMealActive = !_addMealActive;
    notifyListeners();
  }

  void setAddGroceryItemActive() {
    _addGroceryItemActive = !_addGroceryItemActive;
    notifyListeners();
  }

  void setAddBankAccountActive() {
    _addBankAccountActive = !_addBankAccountActive;
    notifyListeners();
  }

  void setAddBudgetActive() {
    _addBudgetActive = !_addBudgetActive;
    notifyListeners();
  }

  void setAddCategoryActive() {
    _addCategoryActive = !_addCategoryActive;
    notifyListeners();
  }

  void setAddTransactionActive() {
    _addTransactionActive = !_addTransactionActive;
    notifyListeners();
  }

  void setAddStockActive() {
    _addStockActive = !_addStockActive;
    notifyListeners();
  }

  void setAddWatchlistStockActive() {
    _addWatchlistStockActive = !_addWatchlistStockActive;
    notifyListeners();
  }

  void setSyncFinanceOverviewActive() {
    _syncFinanceOverviewActive = !_syncFinanceOverviewActive;
    notifyListeners();
  }

  void setSyncFinanceAccountsActive() {
    _syncFinanceAccountsActive = !_syncFinanceAccountsActive;
    notifyListeners();
  }

  void setSyncFinanceTransactionsActive() {
    _syncFinanceTransactionsActive = !_syncFinanceTransactionsActive;
    notifyListeners();
  }

  void setSyncStocksActive() {
    _syncStocksActive = !_syncStocksActive;
    notifyListeners();
  }

  void setRefreshFinanceNewsActive() {
    _refreshFinanceNewsActive = !_refreshFinanceNewsActive;
    notifyListeners();
  }

  void setAIChatActive() {
    _aiChatActive = !_aiChatActive;
    notifyListeners();
  }

  void setRunFinanceAnalysisActive() {
    _runFinanceAnalysisActive = !_runFinanceAnalysisActive;
    notifyListeners();
  }

  void setAddStockPortfolioActive() {
    _addStockPortfolioActive = !_addStockPortfolioActive;
    notifyListeners();
  }

  void setAddAssignmentSubmissionActive() {
    _addAssignmentSubmissionActive = !_addAssignmentSubmissionActive;
    notifyListeners();
  }

  void setAddTopicStudyDocumentActive() {
    _addTopicStudyDocumentActive = !_addTopicStudyDocumentActive;
    notifyListeners();
  }

  void setAddCourseTopicActive() {
    _addCourseTopicActive = !_addCourseTopicActive;
    notifyListeners();
  }

  void setAddPetActive() {
    _addPetActive = !_addPetActive;
    notifyListeners();
  }

  void setAddWorkoutRoutineActive() {
    _addWorkoutRoutineActive = !_addWorkoutRoutineActive;
    notifyListeners();
  }

  void setAddMedicationActive() {
    _addMedicationActive = !_addMedicationActive;
    notifyListeners();
  }

  void setAddMedicalAppointmentActive() {
    _addMedicalAppointmentActive = !_addMedicalAppointmentActive;
    notifyListeners();
  }

  void setSendHouseholdInviteActive() {
    _sendHouseholdInviteActive = !_sendHouseholdInviteActive;
    notifyListeners();
  }

  void setAddChildProfileActive() {
    _addChildProfileActive = !_addChildProfileActive;
    notifyListeners();
  }

  void setAddGroceryListActive() {
    _addGroceryListActive = !_addGroceryListActive;
    notifyListeners();
  }

  void switchHQView(HQView view) {
    if (_hqView != view) {
      _hqView = view;
      notifyListeners();
    }
  }
}