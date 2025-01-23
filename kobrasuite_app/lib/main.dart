import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kobrasuite_app/providers/general/work_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/services/service_locator.dart';
import 'package:kobrasuite_app/services/general/auth_service.dart';
import 'package:kobrasuite_app/providers/general/auth_provider.dart';
import 'package:kobrasuite_app/providers/general/user_profile_provider.dart';
import 'package:kobrasuite_app/providers/general/school_profile_provider.dart';
import 'package:kobrasuite_app/providers/school/university_provider.dart';
import 'package:kobrasuite_app/providers/school/course_provider.dart';
import 'package:kobrasuite_app/providers/school/assignment_provider.dart';
import 'package:kobrasuite_app/providers/school/submission_provider.dart';
import 'package:kobrasuite_app/providers/school/topic_provider.dart';
import 'package:kobrasuite_app/providers/school/study_document_provider.dart';
import 'package:kobrasuite_app/providers/general/theme_notifier.dart';
import 'package:kobrasuite_app/services/general/realtime_service.dart';
import 'package:kobrasuite_app/screens/auth/login_screen.dart';
import 'package:kobrasuite_app/screens/auth/register_screen.dart';
import 'package:kobrasuite_app/screens/home/home_screen.dart';
import 'package:kobrasuite_app/screens/account/settings_screen.dart';
import 'package:kobrasuite_app/themes/green_light_theme.dart';
import 'package:kobrasuite_app/themes/green_dark_theme.dart';
import 'package:kobrasuite_app/themes/blue_light_theme.dart';
import 'package:kobrasuite_app/themes/blue_dark_theme.dart';
import 'package:kobrasuite_app/themes/psychedelic_theme.dart';
import 'package:kobrasuite_app/models/general/app_theme.dart';

import 'auth_wrapper.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await serviceLocator<AuthService>().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (_) => UserProfileProvider(userPk: 0, userProfilePk: 0),
          update: (_, authProvider, userProfileProvider) {
            userProfileProvider!.update(authProvider.userPk, authProvider.userProfilePk);
            return userProfileProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SchoolProfileProvider>(
          create: (_) => SchoolProfileProvider(userPk: 0, schoolProfilePk: 0),
          update: (_, authProvider, schoolProfileProvider) {
            schoolProfileProvider!.update(authProvider.userPk, authProvider.schoolProfilePk);
            return schoolProfileProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WorkProfileProvider>(
          create: (_) => WorkProfileProvider(userPk: 0, workProfilePk: 0),
          update: (_, authProvider, workProfileProvider) {
            workProfileProvider!.update(authProvider.userPk, authProvider.userProfilePk);
            return workProfileProvider;
          },
        ),
        ChangeNotifierProxyProvider<SchoolProfileProvider, UniversityProvider>(
          create: (context) => UniversityProvider(schoolProfileProvider: context.read<SchoolProfileProvider>()),
          update: (_, sp, up) {
            up!.update(sp);
            return up;
          },
        ),
        ChangeNotifierProxyProvider2<SchoolProfileProvider, UniversityProvider, CourseProvider>(
          create: (context) => CourseProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
            universityProvider: context.read<UniversityProvider>(),
          ),
          update: (_, sp, uni, cp) {
            cp!.update(sp, uni);
            return cp;
          },
        ),
        ChangeNotifierProxyProvider3<SchoolProfileProvider, UniversityProvider, CourseProvider, AssignmentProvider>(
          create: (context) => AssignmentProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
            universityProvider: context.read<UniversityProvider>(),
            courseProvider: context.read<CourseProvider>(),
          ),
          update: (_, sp, uni, cp, ap) {
            ap!.update(sp, uni, cp);
            return ap;
          },
        ),
        ChangeNotifierProxyProvider4<SchoolProfileProvider, UniversityProvider, CourseProvider, AssignmentProvider, SubmissionProvider>(
          create: (context) => SubmissionProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
            universityProvider: context.read<UniversityProvider>(),
            courseProvider: context.read<CourseProvider>(),
            assignmentProvider: context.read<AssignmentProvider>(),
          ),
          update: (_, sp, uni, cp, ap, subp) {
            subp!.update(sp, uni, cp, ap);
            return subp;
          },
        ),
        ChangeNotifierProxyProvider3<SchoolProfileProvider, UniversityProvider, CourseProvider, TopicProvider>(
          create: (context) => TopicProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
            universityProvider: context.read<UniversityProvider>(),
            courseProvider: context.read<CourseProvider>(),
          ),
          update: (_, sp, uni, cp, tp) {
            tp!.update(sp, uni, cp);
            return tp;
          },
        ),
        ChangeNotifierProxyProvider4<SchoolProfileProvider, UniversityProvider, CourseProvider, TopicProvider, StudyDocumentProvider>(
          create: (context) => StudyDocumentProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
            universityProvider: context.read<UniversityProvider>(),
            courseProvider: context.read<CourseProvider>(),
            topicProvider: context.read<TopicProvider>(),
          ),
          update: (_, sp, uni, cp, tp, sdp) {
            sdp!.update(sp, uni, cp, tp);
            return sdp;
          },
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider<RealtimeService>(
          create: (_) => serviceLocator<RealtimeService>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) {
          return const KobraSuiteApp();
        },
      ),
    ),
  );
}

class KobraSuiteApp extends StatelessWidget {
  const KobraSuiteApp({super.key});

  ThemeMode _getThemeMode(ThemeNotifier themeNotifier) {
    switch (themeNotifier.currentTheme) {
      case AppTheme.LightGreen:
      case AppTheme.LightBlue:
      case AppTheme.Psychedelic:
        return ThemeMode.light;
      case AppTheme.DarkGreen:
      case AppTheme.DarkBlue:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  ThemeData _getThemeData(ThemeNotifier themeNotifier) {
    switch (themeNotifier.currentTheme) {
      case AppTheme.LightGreen:
        return greenLightTheme;
      case AppTheme.DarkGreen:
        return greenDarkTheme;
      case AppTheme.LightBlue:
        return blueLightTheme;
      case AppTheme.DarkBlue:
        return blueDarkTheme;
      case AppTheme.Psychedelic:
        return psychedelicTheme;
      default:
        return greenLightTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'KobraSuite',
      darkTheme: greenDarkTheme,
      themeMode: _getThemeMode(themeNotifier),
      theme: _getThemeData(themeNotifier),
      navigatorObservers: [routeObserver],
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
