import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/general/auth_provider.dart';
import 'buttons/primary_button.dart';
import 'inputs/rounded_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<void> _onLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    final success = await authProvider.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
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
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 500 ? 400.0 : constraints.maxWidth * 0.9;
          return Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (authProvider.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                authProvider.errorMessage,
                                style: const TextStyle(color: Colors.red),
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
                            isLoading: authProvider.isLoading,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Register here",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
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