import 'package:flutter/foundation.dart';
import 'package:kobrasuite_app/services/homelife/personal_homelife_service.dart';
import '../../models/homelife/workout_routine.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class WorkoutRoutineProvider extends ChangeNotifier {
  final PersonalHomelifeService _workoutService;
  HomeLifeProfileProvider _homelifeProfileProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<WorkoutRoutine> _workoutRoutines = [];

  WorkoutRoutineProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _homelifeProfileProvider = homelifeProfileProvider,
        _workoutService = serviceLocator<PersonalHomelifeService>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WorkoutRoutine> get workoutRoutines => _workoutRoutines;

  int get userPk => _homelifeProfileProvider.userPk;
  int get userProfilePk => _homelifeProfileProvider.userProfilePk;
  int get homelifeProfilePk => _homelifeProfileProvider.homeLifeProfilePk;
  int? get householdPk => _homelifeProfileProvider.householdPk;

  void update(HomeLifeProfileProvider newHomelifeProfileProvider) {
    _homelifeProfileProvider = newHomelifeProfileProvider;
    notifyListeners();
  }

  Future<void> loadWorkoutRoutines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final workoutRoutines = await _workoutService.getWorkoutRoutines(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
      );
      _workoutRoutines = workoutRoutines;
    } catch (e) {
      _errorMessage = 'Error loading workouts: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createWorkoutRoutine({
    ///Needs Completed
    required String title,
    required String description,
    required String schedule,
    required String exercises
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _workoutService.createWorkoutRoutine(
          userPk: userPk,
          userProfilePk: userProfilePk,
          homelifeProfilePk: homelifeProfilePk,
          householdPk: householdPk,
          title: title,
          description: description,
          schedule: schedule,
          exercises: exercises,
      );
      if (success) {
        await loadWorkoutRoutines();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error creating workout routine: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWorkoutRoutine(int workoutRoutineId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _workoutService.deleteWorkoutRoutine(
        userPk: userPk,
        userProfilePk: userProfilePk,
        homelifeProfilePk: homelifeProfilePk,
        householdPk: householdPk,
        workoutRoutineId: workoutRoutineId,
      );
      if (success) {
        _workoutRoutines.removeWhere((a) => a.id == workoutRoutineId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting workout routine: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}