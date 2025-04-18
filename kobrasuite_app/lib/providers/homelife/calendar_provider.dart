import 'package:flutter/foundation.dart';
import 'package:kobrasuite_app/services/homelife/calendar_service.dart';
import '../../models/homelife/shared_calendar_event.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarService _calendarService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<SharedCalendarEvent> _calendarEvents = [];

  CalendarProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _calendarService = serviceLocator<CalendarService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SharedCalendarEvent> get calendarEvents => _calendarEvents;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadCalendarEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final calendarEvents = await _calendarService.getCalendarEvents(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _calendarEvents = calendarEvents;
    } catch (e) {
      _errorMessage = 'Error loading calendar events: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCalendarEvent({
    ///Needs Completed
    required String title,
    required String startDateTime,
    required String endDateTime,
    required String description,
    required String location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _calendarService.createCalendarEvent(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        title: title,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        description: description,
        location: location
      );
      if (success) {
        await loadCalendarEvents();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating calendar event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCalendarEvent(int calendarEventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _calendarService.deleteCalendarEvent(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        calendarEventId: calendarEventId,
      );
      if (success) {
        _calendarEvents.removeWhere((a) => a.id == calendarEventId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting calendar event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}