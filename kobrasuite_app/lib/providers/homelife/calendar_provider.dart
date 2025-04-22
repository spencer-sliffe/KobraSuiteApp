import 'package:flutter/foundation.dart';
import 'package:kobrasuite_app/models/homelife/shared_calendar_event.dart';
import 'package:kobrasuite_app/services/homelife/calendar_service.dart';
import 'package:kobrasuite_app/services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarService _calendarService;
  HomeLifeProfileProvider _profile;

  bool _isLoading = false;
  String? _errorMessage;
  List<SharedCalendarEvent> _calendarEvents = [];

  CalendarProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider,
        _calendarService = serviceLocator<CalendarService>();

  /* ── getters ─────────────────────────────────────────────────────── */
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SharedCalendarEvent> get calendarEvents => _calendarEvents;

  int get _userPk => _profile.userPk;
  int get _userProfilePk => _profile.userProfilePk;
  int get _homelifeProfilePk => _profile.homeLifeProfilePk;
  int? get householdPk => _profile.householdPk;

  /* ── profile hot‑swap ────────────────────────────────────────────── */
  void update(HomeLifeProfileProvider provider) {
    _profile = provider;
    notifyListeners();
  }

  /* ── core loaders ────────────────────────────────────────────────── */
  Future<void> loadCalendarEvents() async {
    if (householdPk == null) return;
    _setLoading(true);
    try {
      _calendarEvents = await _calendarService.getCalendarEvents(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homelifeProfilePk,
        householdPk: householdPk,
      );
    } catch (e) {
      _errorMessage = 'Error loading calendar events: $e';
    }
    _setLoading(false);
  }

  Future<void> loadCalendarEventsRange(DateTime start, DateTime end) async {
    if (householdPk == null) return;
    _setLoading(true);
    try {
      _calendarEvents = await _calendarService.getCalendarEventsRange(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homelifeProfilePk,
        householdPk: householdPk,
        startDateTime: start.toUtc().toIso8601String(),
        endDateTime: end.toUtc().toIso8601String(),
      );
    } catch (e) {
      _errorMessage = 'Error loading calendar events: $e';
    }
    _setLoading(false);
  }

  /* ── CRUD helpers ────────────────────────────────────────────────── */
  Future<bool> createCalendarEvent({
    required String title,
    required String startDateTime,
    required String endDateTime,
    required String description,
    required String location,
  }) async {
    if (householdPk == null) return false;
    _setLoading(true);
    try {
      final ok = await _calendarService.createCalendarEvent(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homelifeProfilePk,
        householdPk: householdPk,
        title: title,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        description: description,
        location: location,
      );
      if (ok) await loadCalendarEvents();
      return ok;
    } catch (e) {
      _errorMessage = 'Error creating calendar event: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCalendarEvent(int id) async {
    if (householdPk == null) return false;
    _setLoading(true);
    try {
      final ok = await _calendarService.deleteCalendarEvent(
        userPk: _userPk,
        userProfilePk: _userProfilePk,
        homelifeProfilePk: _homelifeProfilePk,
        householdPk: householdPk,
        calendarEventId: id,
      );
      if (ok) _calendarEvents.removeWhere((e) => e.id == id);
      return ok;
    } catch (e) {
      _errorMessage = 'Error deleting calendar event: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /* ── util ────────────────────────────────────────────────────────── */
  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _errorMessage = null;
    notifyListeners();
  }
}