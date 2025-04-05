import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/general/auth_provider.dart';
import 'package:kobrasuite_app/UI/screens/main_screen.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';
import 'package:kobrasuite_app/UI/nav/providers/hq_mode_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';

import 'UI/screens/auth/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _didCheckWhoami = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    if (!_didCheckWhoami && authProvider.isLoggedIn) {
      _didCheckWhoami = true;
      authProvider.fetchWhoami().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (authProvider.isLoggedIn) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => HQModeProvider(context.read<NavigationStore>())),
        ],
        child: const MainScreen(),
      );
    } else {
      return const LoginScreen();
    }
  }
}