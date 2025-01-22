import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/school/study_document.dart';
import '../../services/school/study_document_service.dart';
import '../general/school_profile_provider.dart';
import '../school/university_provider.dart';
import '../school/course_provider.dart';
import '../school/topic_provider.dart';
import '../../services/service_locator.dart';

class StudyDocumentProvider extends ChangeNotifier {
  SchoolProfileProvider _schoolProfileProvider;
  UniversityProvider _universityProvider;
  CourseProvider _courseProvider;
  TopicProvider _topicProvider;
  final StudyDocumentService _studyDocumentService;
  List<StudyDocument> _studyDocuments = [];
  bool _isLoading = false;
  String? _errorMessage;
  StudyDocument? _currentStudyDocument;

  StudyDocumentProvider({
    required SchoolProfileProvider schoolProfileProvider,
    required UniversityProvider universityProvider,
    required CourseProvider courseProvider,
    required TopicProvider topicProvider,
  })  : _schoolProfileProvider = schoolProfileProvider,
        _universityProvider = universityProvider,
        _courseProvider = courseProvider,
        _topicProvider = topicProvider,
        _studyDocumentService = serviceLocator<StudyDocumentService>();

  List<StudyDocument> get studyDocuments => _studyDocuments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StudyDocument? get currentStudyDocument => _currentStudyDocument;

  void update(
      SchoolProfileProvider newSchoolProfileProvider,
      UniversityProvider newUniversityProvider,
      CourseProvider newCourseProvider,
      TopicProvider newTopicProvider,
      ) {
    _schoolProfileProvider = newSchoolProfileProvider;
    _universityProvider = newUniversityProvider;
    _courseProvider = newCourseProvider;
    _topicProvider = newTopicProvider;
    notifyListeners();
  }

  void setCurrentStudyDocument(StudyDocument doc) {
    _currentStudyDocument = doc;
    notifyListeners();
  }

  Future<void> fetchStudyDocuments() async {
    if (_topicProvider.currentTopic == null) {
      _errorMessage = 'No topic selected.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final topicPk = _topicProvider.currentTopic!.id;
      final docs = await _studyDocumentService.getStudyDocumentsByTopic(
        userPk: userPk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicPk: topicPk,
      );
      _studyDocuments = docs;
    } catch (e) {
      _errorMessage = 'Failed to load study documents: $e';
      _studyDocuments = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadStudyDocument(File file, {Function(int, int)? onProgress}) async {
    if (_topicProvider.currentTopic == null) {
      _errorMessage = 'No topic selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final topicPk = _topicProvider.currentTopic!.id;
      final newDoc = await _studyDocumentService.uploadStudyDocument(
        userPk: userPk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicPk: topicPk,
        file: file,
        onProgress: onProgress,
      );
      if (newDoc != null) {
        _studyDocuments.add(newDoc);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to upload study document.';
      }
    } catch (e) {
      _errorMessage = 'Error uploading study document: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateStudyDocument(int studyDocumentId, Map<String, dynamic> updatedData) async {
    if (_topicProvider.currentTopic == null) {
      _errorMessage = 'No topic selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final topicPk = _topicProvider.currentTopic!.id;
      final updatedDoc = await _studyDocumentService.updateStudyDocument(
        userPk: userPk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicPk: topicPk,
        studyDocumentPk: studyDocumentId,
        updatedData: updatedData,
      );
      if (updatedDoc != null) {
        final index = _studyDocuments.indexWhere((doc) => doc.id == studyDocumentId);
        if (index != -1) {
          _studyDocuments[index] = updatedDoc;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update study document.';
      }
    } catch (e) {
      _errorMessage = 'Error updating study document: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteStudyDocument(int studyDocumentId) async {
    if (_topicProvider.currentTopic == null) {
      _errorMessage = 'No topic selected.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final topicPk = _topicProvider.currentTopic!.id;
      final success = await _studyDocumentService.deleteStudyDocument(
        userPk: userPk,
        universityPk: universityPk,
        coursePk: coursePk,
        topicPk: topicPk,
        studyDocumentPk: studyDocumentId,
      );
      if (success) {
        _studyDocuments.removeWhere((doc) => doc.id == studyDocumentId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete study document.';
      }
    } catch (e) {
      _errorMessage = 'Error deleting study document: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _studyDocuments = [];
    _errorMessage = null;
    _currentStudyDocument = null;
    notifyListeners();
  }
}