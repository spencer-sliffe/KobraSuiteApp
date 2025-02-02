import 'package:flutter/foundation.dart';
import '../../models/school/university.dart';
import '../../models/school/course.dart';
import '../../models/school/university_news.dart';
import '../../services/school/university_news_service.dart';
import '../../services/school/university_service.dart';
import '../general/school_profile_provider.dart';
import '../../services/service_locator.dart';

class UniversityProvider with ChangeNotifier {
  final UniversityService _universityService;
  final UniversityNewsService _universityNewsService;
  SchoolProfileProvider _schoolProfileProvider;
  University? _currentUniversity;
  List<University> _searchResults = [];
  List<Course> _universityCourses = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<UniversityNews> _trendingNews = [];


  UniversityProvider({required SchoolProfileProvider schoolProfileProvider})
      : _schoolProfileProvider = schoolProfileProvider,
        _universityService = serviceLocator<UniversityService>(),
        _universityNewsService = serviceLocator<UniversityNewsService>();


  University? get currentUniversity => _currentUniversity;
  List<University> get searchResults => _searchResults;
  List<Course> get universityCourses => _universityCourses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get userPk => _schoolProfileProvider.userPk;
  int get schoolProfilePk => _schoolProfileProvider.schoolProfilePk;
  List<UniversityNews> get trendingNews => _trendingNews;


  void update(SchoolProfileProvider newSchoolProfileProvider) {
    _schoolProfileProvider = newSchoolProfileProvider;
    notifyListeners();
  }

  Future<void> loadUserUniversity() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final loaded = await _schoolProfileProvider.loadSchoolProfile();
      if (loaded) {
        final profile = _schoolProfileProvider.profile;
        if (profile != null && profile.universityDetail != null) {
          _currentUniversity = profile.universityDetail;
        } else {
          _currentUniversity = null;
        }
      } else {
        _errorMessage = 'Failed to load school profile.';
        _currentUniversity = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load university: $e';
      _currentUniversity = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchUniversities(String query, {String? country}) async {
    if (query.trim().isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await _universityService.searchUniversities(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        name: query,
        country: country,
      );
      _searchResults = results;
    } catch (e) {
      _errorMessage = 'Failed to search universities: $e';
      _searchResults = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> setUniversity(University uni) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedUniversity = await _universityService.setUserUniversity(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        university: uni,
      );
      _currentUniversity = updatedUniversity;
      await _schoolProfileProvider.loadSchoolProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to set university: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeUniversity(int universityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _universityService.removeUserUniversity(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityId,
      );
      if (success) {
        _currentUniversity = null;
        await _schoolProfileProvider.loadSchoolProfile();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to remove university.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error removing university: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUniversityCourses(int universityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final courses = await _universityService.getAllUniversityCourses(
        userPk: userPk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityId,
      );
      _universityCourses = courses;
    } catch (e) {
      _errorMessage = 'Failed to fetch university courses: $e';
      _universityCourses = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTrendingNews(String universityName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final news = await _universityNewsService.fetchTrendingNews(universityName);
      _trendingNews = news;
    } catch (e) {
      _errorMessage = 'Failed to fetch trending news: $e';
      _trendingNews = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}