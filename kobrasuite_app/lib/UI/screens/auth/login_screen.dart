import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/general/auth_provider.dart';
import 'buttons/primary_button.dart';
import 'inputs/rounded_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<void> _onLogin() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final ok = await auth.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    /*  Success?  AuthProvider notifies AuthWrapper, which replaces
        this screen with MainScreen.  No manual navigation needed.       */
    if (!ok && mounted) {
      final msg = auth.errorMessage;
      if (msg.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth > 500 ? 400.0 : c.maxWidth * .9;

          return Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/KS_SHORT.png',
                        width: 300, height: 300),
                    Transform.translate(
                      offset: const Offset(0, -70),
                      child: Column(
                        children: [
                          Text('Welcome Back',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text('Login to continue',
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 24),

                          /* ── form card ──────────────────────────── */
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                if (auth.errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      auth.errorMessage,
                                      style:
                                      const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                RoundedTextField(
                                  controller: _usernameCtrl,
                                  hintText: 'Username or Email',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                const SizedBox(height: 16),
                                RoundedTextField(
                                  controller: _passwordCtrl,
                                  hintText: 'Password',
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  onPressed: _onLogin,
                                  text: 'Login',
                                  isLoading: auth.isLoading,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Don't have an account? Register here",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const ForgotPasswordScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Forgot password? Reset here",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}