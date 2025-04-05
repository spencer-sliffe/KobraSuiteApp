import 'package:flutter/foundation.dart';
import '../../models/school/assignment.dart';
import '../../services/school/assignment_service.dart';
import '../general/school_profile_provider.dart';
import '../school/university_provider.dart';
import '../school/course_provider.dart';
import '../../services/service_locator.dart';

class AssignmentProvider extends ChangeNotifier {
  SchoolProfileProvider _schoolProfileProvider;
  UniversityProvider _universityProvider;
  CourseProvider _courseProvider;
  final AssignmentService _assignmentService;
  List<Assignment> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;
  Assignment? _currentAssignment;

  AssignmentProvider({
    required SchoolProfileProvider schoolProfileProvider,
    required UniversityProvider universityProvider,
    required CourseProvider courseProvider,
  })  : _schoolProfileProvider = schoolProfileProvider,
        _universityProvider = universityProvider,
        _courseProvider = courseProvider,
        _assignmentService = serviceLocator<AssignmentService>();

  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Assignment? get currentAssignment => _currentAssignment;

  void update(SchoolProfileProvider newSchoolProfileProvider, UniversityProvider newUniversityProvider, CourseProvider newCourseProvider) {
    _schoolProfileProvider = newSchoolProfileProvider;
    _universityProvider = newUniversityProvider;
    _courseProvider = newCourseProvider;
    notifyListeners();
  }

  void setCurrentAssignment(Assignment assignment) {
    _currentAssignment = assignment;
    notifyListeners();
  }

  Future<void> fetchAssignments() async {
    if (_courseProvider.currentCourse == null) {
      _errorMessage = 'No course selected.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk= _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final fetchedAssignments = await _assignmentService.getAssignmentsByCourse(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
      );
      _assignments = fetchedAssignments;
    } catch (e) {
      _errorMessage = 'Failed to load assignments: $e';
      _assignments = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAssignment(Map<String, dynamic> assignmentData) async {
    if (_courseProvider.currentCourse == null) {
      _errorMessage = 'No course selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final success = await _assignmentService.addAssignment(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentData: assignmentData,
      );
      if (success) {
        await fetchAssignments();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add assignment.';
      }
    } catch (e) {
      _errorMessage = 'Error adding assignment: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAssignment(int assignmentId) async {
    if (_courseProvider.currentCourse == null) {
      _errorMessage = 'No course selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final success = await _assignmentService.deleteAssignment(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentId: assignmentId,
      );
      if (success) {
        await fetchAssignments();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete assignment.';
      }
    } catch (e) {
      _errorMessage = 'Error deleting assignment: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _assignments = [];
    _errorMessage = null;
    _currentAssignment = null;
    notifyListeners();
  }
}