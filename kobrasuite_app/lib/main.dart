import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kobrasuite_app/providers/finance/stock_news_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';
import 'package:kobrasuite_app/providers/general/homelife_profile_provider.dart';
import 'package:kobrasuite_app/providers/homelife/calendar_provider.dart';
import 'package:kobrasuite_app/providers/homelife/child_profile_provider.dart';
import 'package:kobrasuite_app/providers/homelife/chore_completion_provider.dart';
import 'package:kobrasuite_app/providers/homelife/chore_provider.dart';
import 'package:kobrasuite_app/providers/homelife/grocery_item_provider.dart';
import 'package:kobrasuite_app/providers/homelife/grocery_list_provider.dart';
import 'package:kobrasuite_app/providers/homelife/household_invite_provider.dart';
import 'package:kobrasuite_app/providers/homelife/household_provider.dart';
import 'package:kobrasuite_app/providers/homelife/meal_provider.dart';
import 'package:kobrasuite_app/providers/homelife/medical_appointment_provider.dart';
import 'package:kobrasuite_app/providers/homelife/medication_provider.dart';
import 'package:kobrasuite_app/providers/homelife/pet_provider.dart';
import 'package:kobrasuite_app/providers/homelife/workout_routine_provider.dart';
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
import 'UI/widgets/detail/finance/bank_account_detail_widget.dart';
import 'auth_wrapper.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await serviceLocator<AuthService>().initialize();
  BankAccountDetailSheet.register();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        /* ─── foundational profile providers (proxied from Auth) ─── */
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (_) => UserProfileProvider(userPk: 0, userProfilePk: 0),
          update: (_, auth, p) => p!..update(auth.userPk, auth.userProfilePk),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SchoolProfileProvider>(
          create: (_) => SchoolProfileProvider(
              userPk: 0, userProfilePk: 0, schoolProfilePk: 0),
          update: (_, auth, p) =>
          p!..update(auth.userPk, auth.userProfilePk, auth.schoolProfilePk),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WorkProfileProvider>(
          create: (_) =>
              WorkProfileProvider(userPk: 0, userProfilePk: 0, workProfilePk: 0),
          update: (_, auth, p) =>
          p!..update(auth.userPk, auth.userProfilePk, auth.workProfilePk),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FinanceProfileProvider>(
          create: (_) => FinanceProfileProvider(
              userPk: 0, userProfilePk: 0, financeProfilePk: 0),
          update: (_, auth, p) =>
          p!..update(auth.userPk, auth.userProfilePk, auth.financeProfilePk),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HomeLifeProfileProvider>(
          create: (_) => HomeLifeProfileProvider(
              userPk: 0, userProfilePk: 0, homeLifeProfilePk: 0),
          update: (_, auth, p) =>
          p!..update(auth.userPk, auth.userProfilePk, auth.homeLifeProfilePk),
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
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, CalendarProvider>(
          create: (context) => CalendarProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, calendarProvider) {
            calendarProvider!.update(homeLifeProfile);
            return calendarProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, WorkoutRoutineProvider>(
          create: (context) => WorkoutRoutineProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, workoutRoutineProvider) {
            workoutRoutineProvider!.update(homeLifeProfile);
            return workoutRoutineProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, ChoreProvider>(
          create: (context) => ChoreProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, choreProvider) {
            choreProvider!.update(homeLifeProfile);
            return choreProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, ChoreCompletionProvider>(
          create: (context) => ChoreCompletionProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, choreCompletionProvider) {
            choreCompletionProvider!.update(homeLifeProfile);
            return choreCompletionProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, GroceryItemProvider>(
          create: (context) => GroceryItemProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, groceryItemProvider) {
            groceryItemProvider!.update(homeLifeProfile);
            return groceryItemProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, GroceryListProvider>(
          create: (context) => GroceryListProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, groceryListProvider) {
            groceryListProvider!.update(homeLifeProfile);
            return groceryListProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, MealProvider>(
          create: (context) => MealProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, mealProvider) {
            mealProvider!.update(homeLifeProfile);
            return mealProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, MedicalAppointmentProvider>(
          create: (context) => MedicalAppointmentProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, medicalAppointmentProvider) {
            medicalAppointmentProvider!.update(homeLifeProfile);
            return medicalAppointmentProvider;
          },
        ),
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, MedicationProvider>(
          create: (context) => MedicationProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, medicationProvider) {
            medicationProvider!.update(homeLifeProfile);
            return medicationProvider;
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
        ChangeNotifierProxyProvider<HomeLifeProfileProvider, ChildProfileProvider>(
          create: (context) => ChildProfileProvider(
            homelifeProfileProvider: context.read<HomeLifeProfileProvider>(),
          ),
          update: (context, homeLifeProfile, childProfileProvider) {
            childProfileProvider!.update(homeLifeProfile);
            return childProfileProvider;
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
        builder: (_, __) => const _KobraSuiteApp(),
      ),
    ),
  );
}

class _KobraSuiteApp extends StatelessWidget {
  const _KobraSuiteApp({super.key});

  ThemeMode _mode(ThemeNotifier t) => switch (t.currentTheme) {
    AppTheme.LightGreen ||
    AppTheme.LightBlue ||
    AppTheme.Psychedelic ||
    AppTheme.UltraModern =>
    ThemeMode.light,
    _ => ThemeMode.dark,
  };

  ThemeData _data(ThemeNotifier t) => switch (t.currentTheme) {
    AppTheme.LightGreen => greenLightTheme,
    AppTheme.DarkGreen => greenDarkTheme,
    AppTheme.LightBlue => blueLightTheme,
    AppTheme.DarkBlue => blueDarkTheme,
    AppTheme.Psychedelic => psychedelicTheme,
    AppTheme.UltraModern => ultraModernTheme,
    _ => greenLightTheme,
  };

  @override
  Widget build(BuildContext context) {
    final tn = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'KobraSuite',
      darkTheme: greenDarkTheme,
      theme: _data(tn),
      themeMode: _mode(tn),
      navigatorObservers: [routeObserver],

      /*  AuthWrapper decides between LoginScreen and MainScreen.     */
      home: const AuthWrapper(),

      /*  NOTE: `/home` removed intentionally — do NOT push it.       */
      routes: {
        '/login': (_) => const AuthWrapper(),
        '/register': (_) => const RegisterScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/account': (_) => const AccountScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-confirm': (_) => const PasswordResetConfirmScreen(),
      },
    );
  }
}