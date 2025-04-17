import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kobrasuite_app/providers/finance/stock_news_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';
import 'package:kobrasuite_app/providers/general/homelife_profile_provider.dart';
import 'package:kobrasuite_app/providers/homelife/household_invite_provider.dart';
import 'package:kobrasuite_app/providers/homelife/household_provider.dart';
import 'package:kobrasuite_app/providers/homelife/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/services/service_locator.dart';
import 'package:kobrasuite_app/services/general/auth_service.dart';
import 'package:kobrasuite_app/providers/general/auth_provider.dart';
import 'package:kobrasuite_app/providers/general/user_profile_provider.dart';
import 'package:kobrasuite_app/providers/general/school_profile_provider.dart';
import 'package:kobrasuite_app/providers/general/work_profile_provider.dart';
import 'package:kobrasuite_app/providers/general/finance_profile_provider.dart';
import 'package:kobrasuite_app/providers/general/theme_notifier.dart';
import 'package:kobrasuite_app/providers/school/university_provider.dart';
import 'package:kobrasuite_app/providers/school/course_provider.dart';
import 'package:kobrasuite_app/providers/school/assignment_provider.dart';
import 'package:kobrasuite_app/providers/school/submission_provider.dart';
import 'package:kobrasuite_app/providers/school/topic_provider.dart';
import 'package:kobrasuite_app/providers/school/study_document_provider.dart';
import 'package:kobrasuite_app/services/general/realtime_service.dart';
import 'package:kobrasuite_app/UI/screens/auth/login_screen.dart';
import 'package:kobrasuite_app/UI/screens/auth/register_screen.dart';
import 'package:kobrasuite_app/UI/screens/account/settings_screen.dart';
import 'package:kobrasuite_app/UI/themes/green_light_theme.dart';
import 'package:kobrasuite_app/UI/themes/green_dark_theme.dart';
import 'package:kobrasuite_app/UI/themes/blue_light_theme.dart';
import 'package:kobrasuite_app/UI/themes/blue_dark_theme.dart';
import 'package:kobrasuite_app/UI/themes/psychedelic_theme.dart';
import 'package:kobrasuite_app/UI/themes/ultra_modern_theme.dart';
import 'package:kobrasuite_app/models/general/app_theme.dart';
import 'package:kobrasuite_app/providers/finance/stock_portfolio_provider.dart';
import 'package:kobrasuite_app/providers/finance/stock_provider.dart';
import 'package:kobrasuite_app/providers/finance/bank_account_provider.dart';
import 'package:kobrasuite_app/providers/finance/budget_provider.dart';
import 'package:kobrasuite_app/providers/finance/budget_category_provider.dart';
import 'package:kobrasuite_app/providers/finance/transaction_provider.dart';
import 'UI/nav/providers/navigation_store.dart';
import 'UI/screens/account/account_screen.dart';
import 'UI/screens/auth/forgot_password_screen.dart';
import 'UI/screens/auth/password_reset_confirm_screen.dart';
import 'UI/screens/main_screen.dart';
import 'auth_wrapper.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await serviceLocator<AuthService>().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (_) => UserProfileProvider(userPk: 0, userProfilePk: 0),
          update: (_, auth, userProfile) {
            userProfile!.update(auth.userPk, auth.userProfilePk);
            return userProfile;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SchoolProfileProvider>(
          create: (_) => SchoolProfileProvider(userPk: 0, userProfilePk: 0, schoolProfilePk: 0),
          update: (_, auth, schoolProfile) {
            schoolProfile!.update(auth.userPk, auth.userProfilePk, auth.schoolProfilePk);
            return schoolProfile;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WorkProfileProvider>(
          create: (_) => WorkProfileProvider(userPk: 0, userProfilePk: 0, workProfilePk: 0),
          update: (_, auth, workProfile) {
            workProfile!.update(auth.userPk, auth.userProfilePk, auth.workProfilePk);
            return workProfile;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FinanceProfileProvider>(
          create: (_) => FinanceProfileProvider(userPk: 0, userProfilePk: 0, financeProfilePk: 0),
          update: (_, auth, financeProfile) {
            financeProfile!.update(auth.userPk, auth.userProfilePk, auth.financeProfilePk);
            return financeProfile;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, HomeLifeProfileProvider>(
          create: (_) => HomeLifeProfileProvider(userPk: 0, userProfilePk: 0, homeLifeProfilePk: 0),
          update: (_, auth, homeLifeProfile) {
            homeLifeProfile!.update(auth.userPk, auth.userProfilePk, auth.homeLifeProfilePk);
            return homeLifeProfile;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, HouseholdProvider>(
          create: (context) => HouseholdProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, householdProvider) {
            householdProvider!.update(homeLifeProfile);
            return householdProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, PetProvider>(
          create: (context) => PetProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, petProvider) {
            petProvider!.update(homeLifeProfile);
            return petProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, HouseholdInviteProvider>(
          create: (context) => HouseholdInviteProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, householdInviteProvider) {
            householdInviteProvider!.update(homeLifeProfile);
            return householdInviteProvider;
          },
        ),
        ChangeNotifierProxyProvider<SchoolProfileProvider, UniversityProvider>(
          create: (context) => UniversityProvider(
            schoolProfileProvider: context.read<SchoolProfileProvider>(),
          ),
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
          update: (_, sp, uni, cp, ap, sub) {
            sub!.update(sp, uni, cp, ap);
            return sub;
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
        ChangeNotifierProxyProvider<FinanceProfileProvider, BankAccountProvider>(
          create: (context) => BankAccountProvider(
              financeProfileProvider: context.read<FinanceProfileProvider>()),
          update: (context, financeProfile, bankAccountProvider) {
            bankAccountProvider!.update(financeProfile);
            return bankAccountProvider;
          },
        ),
        ChangeNotifierProxyProvider<FinanceProfileProvider, BudgetProvider>(
          create: (context) => BudgetProvider(
              financeProfileProvider: context.read<FinanceProfileProvider>()),
          update: (context, financeProfile, budgetProvider) {
            budgetProvider!.update(financeProfile);
            return budgetProvider;
          },
        ),
        ChangeNotifierProxyProvider<FinanceProfileProvider, BudgetCategoryProvider>(
          create: (context) => BudgetCategoryProvider(
              financeProfileProvider: context.read<FinanceProfileProvider>()),
          update: (context, financeProfile, categoryProvider) {
            categoryProvider!.update(financeProfile);
            return categoryProvider;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, FinanceProfileProvider, TransactionProvider>(
          create: (_) => TransactionProvider(userPk: 0, userProfilePk: 0, financeProfilePk: 0),
          update: (_, auth, financeProfile, transactionProvider) {
            transactionProvider!.update(
              newUserPk: auth.userPk,
              newUserProfilePk: auth.userProfilePk,
              newFinanceProfilePk: financeProfile.financeProfile?.id ?? 0,
            );
            return transactionProvider;
          },
        ),
        ChangeNotifierProvider<NavigationStore>(create: (_) => NavigationStore()),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider<RealtimeService>(create: (_) => serviceLocator<RealtimeService>()),
        ChangeNotifierProxyProvider2<AuthProvider, FinanceProfileProvider, StockPortfolioProvider>(
          create: (_) => StockPortfolioProvider(userPk: 0, userProfilePk:0, financeProfilePk: 0, stockPortfolioPk: 0),
          update: (_, auth, finance, sp) {
            sp!.update(
              newUserPk: auth.userPk,
              newUserProfilePk: auth.userProfilePk,
              newFinanceProfilePk: finance.financeProfile?.id ?? 0,
              newStockPortfolioPk: sp.stockPortfolioPk,
            );
            return sp;
          },
        ),
        ChangeNotifierProxyProvider3<AuthProvider, FinanceProfileProvider, StockPortfolioProvider, StockProvider>(
          create: (_) => StockProvider(userPk: 0, userProfilePk: 0, financeProfilePk: 0, stockPortfolioPk: 0),
          update: (_, auth, finance, spPortfolio, s) {
            s!.update(
              newUserPk: auth.userPk,
              newUserProfilePk: auth.userProfilePk,
              newFinanceProfilePk: finance.financeProfile?.id ?? 0,
              newStockPortfolioPk: spPortfolio.stockPortfolioPk,
            );
            return s;
          },
        ),
        ChangeNotifierProvider<StockNewsProvider>(create: (_) => StockNewsProvider()),
        ChangeNotifierProvider<ControlBarProvider>(create: (_) => ControlBarProvider()),
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
      case AppTheme.UltraModern:
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
      case AppTheme.UltraModern:
        return ultraModernTheme;
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
        '/home': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/account': (context) => const AccountScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-confirm': (context) => const PasswordResetConfirmScreen(),
      },
    );
  }
}