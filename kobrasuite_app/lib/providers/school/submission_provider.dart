// File location: lib/providers/school/submission_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/school/submission.dart';
import '../../services/school/submission_service.dart';
import '../general/school_profile_provider.dart';
import '../school/university_provider.dart';
import '../school/course_provider.dart';
import '../school/assignment_provider.dart';
import '../../services/service_locator.dart';

class SubmissionProvider extends ChangeNotifier {
  SchoolProfileProvider _schoolProfileProvider;
  UniversityProvider _universityProvider;
  CourseProvider _courseProvider;
  AssignmentProvider _assignmentProvider;
  final SubmissionService _submissionService;
  List<Submission> _submissions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Submission? _currentSubmission;

  SubmissionProvider({
    required SchoolProfileProvider schoolProfileProvider,
    required UniversityProvider universityProvider,
    required CourseProvider courseProvider,
    required AssignmentProvider assignmentProvider,
  })  : _schoolProfileProvider = schoolProfileProvider,
        _universityProvider = universityProvider,
        _courseProvider = courseProvider,
        _assignmentProvider = assignmentProvider,
        _submissionService = serviceLocator<SubmissionService>();

  List<Submission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Submission? get currentSubmission => _currentSubmission;

  void update(
      SchoolProfileProvider newSchoolProfileProvider,
      UniversityProvider newUniversityProvider,
      CourseProvider newCourseProvider,
      AssignmentProvider newAssignmentProvider,
      ) {
    _schoolProfileProvider = newSchoolProfileProvider;
    _universityProvider = newUniversityProvider;
    _courseProvider = newCourseProvider;
    _assignmentProvider = newAssignmentProvider;
    notifyListeners();
  }

  void setCurrentSubmission(Submission submission) {
    _currentSubmission = submission;
    notifyListeners();
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final fetchedSubmissions = await _submissionService.getSubmissionsByAssignment(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentId,
      );
      _submissions = fetchedSubmissions;
    } catch (e) {
      _errorMessage = 'Failed to load submissions: $e';
      _submissions = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Submission?> createSubmission(int assignmentId, Map<String, dynamic> submissionData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final submission = await _submissionService.createSubmission(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentId,
        submissionData: submissionData,
      );
      if (submission != null) {
        await fetchSubmissions(assignmentId);
        _isLoading = false;
        notifyListeners();
        return submission;
      } else {
        _errorMessage = 'Failed to create submission.';
      }
    } catch (e) {
      _errorMessage = 'Error creating submission: $e';
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> uploadAnswerFile({
    required int assignmentId,
    required int submissionId,
    required File file,
    Function(int, int)? onProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final success = await _submissionService.uploadAnswer(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentId,
        submissionPk: submissionId,
        file: file,
        onProgress: onProgress,
      );
      if (success) {
        await fetchSubmissions(assignmentId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to upload answer file.';
      }
    } catch (e) {
      _errorMessage = 'Error uploading answer file: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> addCommentToSubmission({
    required int assignmentId,
    required int submissionId,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final success = await _submissionService.addComment(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentId,
        submissionPk: submissionId,
        comment: comment,
      );
      if (success) {
        await fetchSubmissions(assignmentId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add comment.';
      }
    } catch (e) {
      _errorMessage = 'Error adding comment: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Submission?> getSubmissionDetail(int assignmentId, int submissionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userPk = _schoolProfileProvider.userPk;
      final userProfilePk = _schoolProfileProvider.userProfilePk;
      final schoolProfilePk = _schoolProfileProvider.schoolProfilePk;
      final universityPk = _universityProvider.currentUniversity!.id;
      final coursePk = _courseProvider.currentCourse!.id;
      final submission = await _submissionService.getSubmissionDetail(
        userPk: userPk,
        userProfilePk: userProfilePk,
        schoolProfilePk: schoolProfilePk,
        universityPk: universityPk,
        coursePk: coursePk,
        assignmentPk: assignmentId,
        submissionPk: submissionId,
      );
      if (submission != null) {
        _currentSubmission = submission;
        _isLoading = false;
        notifyListeners();
        return submission;
      }
      _errorMessage = 'Submission not found.';
    } catch (e) {
      _errorMessage = 'Error fetching submission details: $e';
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  void clear() {
    _submissions = [];
    _errorMessage = null;
    _currentSubmission = null;
    notifyListeners();
  }
}