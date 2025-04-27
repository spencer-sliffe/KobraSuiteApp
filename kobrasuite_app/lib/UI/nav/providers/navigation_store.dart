import 'package:flutter/material.dart';

import '../../../models/detail_target.dart';

enum Module { Finances, HomeLife, School, Work }
enum HQView { Dashboard, ModuleManager }

class NavigationStore extends ChangeNotifier {
  //Module Control
  List<Module> _moduleOrder = Module.values.toList();
  Module _activeModule = Module.Finances;
  bool _hqActive = false;
  HQView _hqView = HQView.Dashboard;
  VoidCallback? _refreshCallback;

  DetailTarget? _detailTarget;
  DetailTarget? get detailTarget => _detailTarget;
  bool get detailActive => _detailTarget != null;

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
  bool _addHouseholdActive = false;


  List<Module> get moduleOrder => _moduleOrder;
  Module get activeModule => _activeModule;
  bool get hqActive => _hqActive;
  HQView get hqView => _hqView;
  VoidCallback? get refreshCallback => _refreshCallback;
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
  bool get addHouseholdActive => _addHouseholdActive;

  void _clearAllOverlayFlags() {
    _searchUniversityActive = false;
    _addCourseActive = false;
    _addProjectActive = false;
    _addTeamActive = false;
    _addTaskActive = false;
    _addChoreActive = false;
    _addCalendarEventActive = false;
    _addMealActive = false;
    _addBankAccountActive = false;
    _addBudgetActive = false;
    _addCategoryActive = false;
    _addTransactionActive = false;
    _addStockActive = false;
    _addWatchlistStockActive = false;
    _syncFinanceOverviewActive = false;
    _syncFinanceAccountsActive = false;
    _syncFinanceTransactionsActive = false;
    _syncStocksActive = false;
    _refreshFinanceNewsActive = false;
    _runFinanceAnalysisActive = false;
    _addStockPortfolioActive = false;
    _addTopicStudyDocumentActive = false;
    _addCourseTopicActive = false;
    _addAssignmentSubmissionActive = false;
    _addPetActive = false;
    _addMedicationActive = false;
    _addMedicalAppointmentActive = false;
    _sendHouseholdInviteActive = false;
    _addWorkoutRoutineActive = false;
    _addChildProfileActive = false;
    _addGroceryListActive = false;
    _addGroceryItemActive = false;
    _addHouseholdActive = false;
  }

  void setModuleOrder(List<Module> newOrder) {
    _moduleOrder = newOrder;
    notifyListeners();
  }

  void setActiveModule(Module module) {
    _clearAllOverlayFlags();
    _activeModule = module;
    notifyListeners();
  }

  void setActiveFinancesTabIndex(int index) {
    if (_activeFinancesTabIndex != index) {
      _clearAllOverlayFlags();
      _activeFinancesTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveSchoolTabIndex(int index) {
    if (_activeSchoolTabIndex != index) {
      _clearAllOverlayFlags();
      _activeSchoolTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveHomeLifeTabIndex(int index) {
    if (_activeHomeLifeTabIndex != index) {
      _clearAllOverlayFlags();
      _activeHomeLifeTabIndex = index;
      notifyListeners();
    }
  }

  void setActiveWorkTabIndex(int index) {
    if (_activeWorkTabIndex != index) {
      _clearAllOverlayFlags();
      _activeWorkTabIndex = index;
      notifyListeners();
    }
  }

  void toggleHQ() {
    _clearAllOverlayFlags();
    _hqActive = !_hqActive;
    notifyListeners();
  }

  void setSearchUniversityActive() {
    if (_searchUniversityActive) {
      _searchUniversityActive = !_searchUniversityActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _searchUniversityActive = !_searchUniversityActive;
    }
    notifyListeners();
  }

  void setAddCourseActive() {
    if (_addCourseActive) {
      _addCourseActive = !_addCourseActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addCourseActive = !_addCourseActive;
    }
    notifyListeners();
  }

  void setAddProjectActive() {
    if (_addProjectActive) {
      _addProjectActive = !_addProjectActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addProjectActive = !_addProjectActive;
    }
    notifyListeners();
  }

  void setAddTeamActive() {
    if (_addTeamActive) {
      _addTeamActive = !_addTeamActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addTeamActive = !_addTeamActive;
    }
    notifyListeners();
  }

  void setAddTaskActive() {
    if (_addTaskActive) {
      _addTaskActive = !_addTaskActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addTaskActive = !_addTaskActive;
    }
    notifyListeners();
  }

  void setAddChoreActive() {
    if (_addChoreActive) {
      _addChoreActive = !_addChoreActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addChoreActive = !_addChoreActive;
    }
    notifyListeners();
  }

  void setAddCalendarEventActive() {
    if (_addCalendarEventActive) {
      _addCalendarEventActive = !_addCalendarEventActive;
    }
    else {
      _clearAllOverlayFlags();
      _addCalendarEventActive = !_addCalendarEventActive;
    }
    notifyListeners();
  }

  void setAddMealActive() {
    if (_addMealActive) {
      _addMealActive = !_addMealActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addMealActive = !_addMealActive;
    }
    notifyListeners();
  }

  void setAddGroceryItemActive() {
    if (_addGroceryItemActive) {
      _addGroceryItemActive = !_addGroceryItemActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addGroceryItemActive = !_addGroceryItemActive;
    }
    notifyListeners();
  }

  void setAddBankAccountActive() {
    if (_addBankAccountActive) {
      _addBankAccountActive = !_addBankAccountActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addBankAccountActive = !_addBankAccountActive;
    }
    notifyListeners();
  }

  void setAddBudgetActive() {
    if (_addBudgetActive) {
      _addBudgetActive = !_addBudgetActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addBudgetActive = !_addBudgetActive;
    }
    notifyListeners();
  }

  void setAddCategoryActive() {
    if (_addCategoryActive) {
      _addCategoryActive = !_addCategoryActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addCategoryActive = !_addCategoryActive;
    }
    notifyListeners();
  }

  void setAddTransactionActive() {
    if (_addTransactionActive) {
      _addTransactionActive = !_addTransactionActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addTransactionActive = !_addTransactionActive;
    }
    notifyListeners();
  }

  void setAddStockActive() {
    if (_addStockActive) {
      _addStockActive = !_addStockActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addStockActive = !_addStockActive;
    }
    notifyListeners();
  }

  void setAddWatchlistStockActive() {
    if (_addWatchlistStockActive) {
      _addWatchlistStockActive = !_addWatchlistStockActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addWatchlistStockActive = !_addWatchlistStockActive;
    }
    notifyListeners();
  }

  void setSyncFinanceOverviewActive() {
    if (_syncFinanceOverviewActive) {
      _syncFinanceOverviewActive = !_syncFinanceOverviewActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _syncFinanceOverviewActive = !_syncFinanceOverviewActive;
    }
    notifyListeners();
  }

  void setSyncFinanceAccountsActive() {
    if (_syncFinanceAccountsActive) {
      _syncFinanceAccountsActive = !_syncFinanceAccountsActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _syncFinanceAccountsActive = !_syncFinanceAccountsActive;
    }
    notifyListeners();
  }

  void setSyncFinanceTransactionsActive() {
    if (_syncFinanceTransactionsActive) {
      _syncFinanceTransactionsActive = !_syncFinanceTransactionsActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _syncFinanceTransactionsActive = !_syncFinanceTransactionsActive;
    }
    notifyListeners();
  }

  void setSyncStocksActive() {
    if (_syncStocksActive) {
      _syncStocksActive = !_syncStocksActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _syncStocksActive = !_syncStocksActive;
    }
    notifyListeners();
  }

  void setRefreshFinanceNewsActive() {
    if (_refreshFinanceNewsActive) {
      _refreshFinanceNewsActive = !_refreshFinanceNewsActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _refreshFinanceNewsActive = !_refreshFinanceNewsActive;
    }
    notifyListeners();
  }

  void setAIChatActive() {
    _aiChatActive = !_aiChatActive;
    notifyListeners();
  }

  void setRunFinanceAnalysisActive() {
    if (_runFinanceAnalysisActive) {
      _runFinanceAnalysisActive = !_runFinanceAnalysisActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _runFinanceAnalysisActive = !_runFinanceAnalysisActive;
    }
    notifyListeners();
  }

  void setAddStockPortfolioActive() {
    if (_addStockPortfolioActive) {
      _addStockPortfolioActive = !_addStockPortfolioActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addStockPortfolioActive = !_addStockPortfolioActive;
    }
    notifyListeners();
  }

  void setAddAssignmentSubmissionActive() {
    if (_addAssignmentSubmissionActive) {
      _addAssignmentSubmissionActive = !_addAssignmentSubmissionActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addAssignmentSubmissionActive = !_addAssignmentSubmissionActive;
    }
    notifyListeners();
  }

  void setAddTopicStudyDocumentActive() {
    if (_addTopicStudyDocumentActive) {
      _addTopicStudyDocumentActive = !_addTopicStudyDocumentActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addTopicStudyDocumentActive = !_addTopicStudyDocumentActive;
    }
    notifyListeners();
  }

  void setAddCourseTopicActive() {
    if (_addCourseTopicActive) {
      _addCourseTopicActive = !_addCourseTopicActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addCourseTopicActive = !_addCourseTopicActive;
    }
    notifyListeners();
  }

  void setAddPetActive() {
    if (_addPetActive) {
      _addPetActive = !_addPetActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addPetActive = !_addPetActive;
    }
    notifyListeners();
  }

  void setAddWorkoutRoutineActive() {
    if (_addWorkoutRoutineActive) {
      _addWorkoutRoutineActive = !_addWorkoutRoutineActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addWorkoutRoutineActive = !_addWorkoutRoutineActive;
    }
    notifyListeners();
  }

  void setAddMedicationActive() {
    if (_addMedicationActive) {
      _addMedicationActive = !_addMedicationActive;
    }
    else {
      _clearAllOverlayFlags();
      _addMedicationActive = !_addMedicationActive;
    }
    notifyListeners();
  }

  void setAddMedicalAppointmentActive() {
    if (_addMedicalAppointmentActive) {
      _addMedicalAppointmentActive = !_addMedicalAppointmentActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addMedicalAppointmentActive = !_addMedicalAppointmentActive;
    }
    notifyListeners();
  }

  void setSendHouseholdInviteActive() {
    if (_sendHouseholdInviteActive) {
      _sendHouseholdInviteActive = !_sendHouseholdInviteActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _sendHouseholdInviteActive = !_sendHouseholdInviteActive;
    }
    notifyListeners();
  }

  void setAddChildProfileActive() {
    if (_addChildProfileActive) {
      _addChildProfileActive = !_addChildProfileActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addChildProfileActive = !_addChildProfileActive;
    }
    notifyListeners();
  }

  void setAddGroceryListActive() {
    if (_addGroceryListActive) {
      _addGroceryListActive = !_addGroceryListActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addGroceryListActive = !_addGroceryListActive;
    }
    notifyListeners();
  }

  void setAddHouseholdActive() {
    if (_addHouseholdActive) {
      _addHouseholdActive = !_addHouseholdActive;
    }
    else
    {
      _clearAllOverlayFlags();
      _addHouseholdActive = !_addHouseholdActive;
    }
    notifyListeners();
  }

  void setRefreshCallback(VoidCallback callback) {
    _refreshCallback = callback;
    notifyListeners();
  }

  void clearRefreshCallback() {
    _refreshCallback = null;
    notifyListeners();
  }

  void switchHQView(HQView view) {
    if (_hqView != view) {
      _hqView = view;
      notifyListeners();
    }
  }

  void showDetail(DetailTarget t) {
    _clearAllOverlayFlags();
    _detailTarget = t;
    notifyListeners();
  }

  void closeDetail() {
    _detailTarget = null;
    notifyListeners();
  }
}