// lib/services/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import all your services here
import 'general/auth_service.dart';
import 'general/user_profile_service.dart';
import 'general/school_profile_service.dart';
import 'general/work_profile_service.dart';
import 'school/university_service.dart';
import 'school/course_service.dart';
import 'school/assignment_service.dart';
import 'school/submission_service.dart';
import 'school/topic_service.dart';
import 'school/study_document_service.dart';
import 'school/discussion_service.dart';
import 'general/realtime_service.dart';
import 'dio_client.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register DioClient as a singleton
  serviceLocator.registerLazySingleton<DioClient>(() => DioClient());

  // Register Dio as a singleton using the DioClient
  serviceLocator.registerLazySingleton<Dio>(() => serviceLocator<DioClient>().dio);

  // Register FlutterSecureStorage as a singleton
  serviceLocator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Register AuthService as a singleton (depends on Dio and FlutterSecureStorage)
  serviceLocator.registerLazySingleton<AuthService>(
        () => AuthService(
      serviceLocator<Dio>(),
      serviceLocator<FlutterSecureStorage>(),
    ),
  );

  // Register UserProfileService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<UserProfileService>(
        () => UserProfileService(serviceLocator<Dio>()),
  );

  // Register WorkProfileService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<WorkProfileService>(
        () => WorkProfileService(serviceLocator<Dio>()),
  );

  // Register SchoolProfileService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<SchoolProfileService>(
        () => SchoolProfileService(serviceLocator<Dio>()),
  );

  // Register UniversityService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<UniversityService>(
        () => UniversityService(serviceLocator<Dio>()),
  );

  // Register CourseService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<CourseService>(
        () => CourseService(serviceLocator<Dio>()),
  );

  // Register AssignmentService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<AssignmentService>(
        () => AssignmentService(serviceLocator<Dio>()),
  );

  // Register SubmissionService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<SubmissionService>(
        () => SubmissionService(serviceLocator<Dio>()),
  );

  // Register TopicService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<TopicService>(
        () => TopicService(serviceLocator<Dio>()),
  );

  // Register StudyDocumentService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<StudyDocumentService>(
        () => StudyDocumentService(serviceLocator<Dio>()),
  );

  // Register DiscussionService as a singleton (depends on Dio)
  serviceLocator.registerLazySingleton<DiscussionService>(
        () => DiscussionService(serviceLocator<Dio>(), serviceLocator<AuthService>()),
  );

  // Register RealtimeService as a singleton (depends on Dio, DiscussionService, AuthService)
  serviceLocator.registerLazySingleton<RealtimeService>(
        () => RealtimeService(
      serviceLocator<Dio>(),
      serviceLocator<DiscussionService>(),
      serviceLocator<AuthService>(),
    ),
  );

  // Add other services here as needed
}