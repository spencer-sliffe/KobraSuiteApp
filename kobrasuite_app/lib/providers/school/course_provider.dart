import 'package:flutter/material.dart';
import '../../models/school/course.dart';
import '../../services/school/course_service.dart';
import '../general/school_profile_provider.dart';
import '../school/university_provider.dart';
import '../../services/service_locator.dart';

class CourseProvider with ChangeNotifier {
  SchoolProfileProvider _schoolProfileProvider;
  UniversityProvider _universityProvider;
  final CourseService _courseService;
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;
  Course? _currentCourse;

  CourseProvider({
    required SchoolProfileProvider schoolProfileProvider,
    required UniversityProvider universityProvider,
  })  : _schoolProfileProvider = schoolProfileProvider,
        _universityProvider = universityProvider,
        _courseService = serviceLocator<CourseService>();

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Course? get currentCourse => _currentCourse;
  int get userPk => _schoolProfileProvider.userPk;
  int get schoolProfilePk => _schoolProfileProvider.schoolProfilePk;

  void update(SchoolProfileProvider s, UniversityProvider u) {
    _schoolProfileProvider = s;
    _universityProvider = u;
    notifyListeners();
  }

  void setCurrentCourse(Course course) {
    _currentCourse = course;
    notifyListeners();
  }

  Future<void> fetchCourses() async {
    if (_universityProvider.currentUniversity == null) {
      _errorMessage = 'No university selected.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final universityPk = _universityProvider.currentUniversity!.id;
      final results = await _courseService.searchCoursesInUniversity(
          userPk: userPk,
          schoolProfilePk: schoolProfilePk,
          universityPk: universityPk,
          query: '',
      );
      _courses = results;
    } catch (e) {
      _errorMessage = 'Failed to load courses: $e';
      _courses = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCourseToProfile(int courseId) async {
    if (_universityProvider.currentUniversity == null) {
      _errorMessage = 'No university selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      await _courseService.addCourseToSchoolProfile(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        courseId: courseId,
      );
      await fetchCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeCourseFromProfile(int courseId) async {
    if (_universityProvider.currentUniversity == null) {
      _errorMessage = 'No university selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      await _courseService.removeCourseFromSchoolProfile(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        courseId: courseId,
      );
      await fetchCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> verifyCourseData({
    required String courseCode,
    required String title,
    required String professorLastName,
    required String department,
    required String semesterType,
  }) async {
    if (_universityProvider.currentUniversity == null) {
      return {
        'foundExactMatch': false,
        'correctedCourseData': null,
        'error': 'No university selected.'
      };
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final userPk = _schoolProfileProvider.userPk;
    final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
    final universityPk = _universityProvider.currentUniversity!.id;
    try {
      final result = await _courseService.verifyCourse(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        courseData: {
          'course_code': courseCode,
          'course_title': title,
          'professor_last_name': professorLastName,
          'department': department,
          'semester_type': semesterType,
        },
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'foundExactMatch': false,
        'correctedCourseData': null,
        'error': 'Failed to verify course: $e'
      };
    }
  }

  Future<bool> addNewCourse({
    required String courseCode,
    required String title,
    required String professorLastName,
    required String department,
    required String semesterType,
    required int semesterYear,
  }) async {
    if (_universityProvider.currentUniversity == null) {
      _errorMessage = 'No university selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final userPk = _schoolProfileProvider.userPk;
    final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
    final universityPk = _universityProvider.currentUniversity!.id;
    final payload = {
      'course_code': courseCode,
      'title': title,
      'professor_last_name': professorLastName,
      'department': department,
      'semester_type': semesterType,
      'semester_year': semesterYear,
    };
    try {
      await _courseService.createCourseInUniversity(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        courseData: payload,
      );
      await fetchCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create course: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}