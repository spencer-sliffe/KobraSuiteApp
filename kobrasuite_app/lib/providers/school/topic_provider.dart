import 'package:flutter/foundation.dart';
import '../../models/school/topic.dart';
import '../../services/school/topic_service.dart';
import '../general/school_profile_provider.dart';
import '../school/university_provider.dart';
import '../school/course_provider.dart';
import '../../services/service_locator.dart';

class TopicProvider extends ChangeNotifier {
  SchoolProfileProvider _schoolProfileProvider;
  UniversityProvider _universityProvider;
  CourseProvider _courseProvider;
  final TopicService _topicService;
  List<Topic> _topics = [];
  bool _isLoading = false;
  String? _errorMessage;
  Topic? _currentTopic;

  TopicProvider({
    required SchoolProfileProvider schoolProfileProvider,
    required UniversityProvider universityProvider,
    required CourseProvider courseProvider,
  })  : _schoolProfileProvider = schoolProfileProvider,
        _universityProvider = universityProvider,
        _courseProvider = courseProvider,
        _topicService = serviceLocator<TopicService>();

  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Topic? get currentTopic => _currentTopic;

  void update(
      SchoolProfileProvider newSchoolProfileProvider,
      UniversityProvider newUniversityProvider,
      CourseProvider newCourseProvider,
      ) {
    _schoolProfileProvider = newSchoolProfileProvider;
    _universityProvider = newUniversityProvider;
    _courseProvider = newCourseProvider;
    notifyListeners();
  }

  void setCurrentTopic(Topic topic) {
    _currentTopic = topic;
    notifyListeners();
  }

  Future<void> fetchTopics() async {
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
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final fetchedTopics = await _topicService.getTopicsByCourse(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
      );
      _topics = fetchedTopics;
    } catch (e) {
      _errorMessage = 'Failed to load topics: $e';
      _topics = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTopic(String name) async {
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
      final topic = await _topicService.addTopic(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        name: name,
      );
      _topics.add(topic);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding topic: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateTopic(int topicId, String newName) async {
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
      final updated = await _topicService.updateTopic(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicId: topicId,
        newName: newName,
      );
      final index = _topics.indexWhere((t) => t.id == topicId);
      if (index != -1) {
        _topics[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating topic: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteTopic(int topicId) async {
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
      final success = await _topicService.deleteTopic(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicId: topicId,
      );
      if (success) {
        _topics.removeWhere((t) => t.id == topicId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete topic.';
      }
    } catch (e) {
      _errorMessage = 'Error deleting topic: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _topics = [];
    _errorMessage = null;
    _currentTopic = null;
    notifyListeners();
  }
}