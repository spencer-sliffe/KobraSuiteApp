import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/general/auth_provider.dart';
import 'buttons/primary_button.dart';
import 'inputs/rounded_text_field.dart';
import 'login_screen.dart';
import 'password_reset_confirm_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRequestReset() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    final success = await authProvider.passwordResetRequest(_emailCtrl.text.trim());
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PasswordResetConfirmScreen()),
      );
    }
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
                    Transform.translate(
                      offset: const Offset(0, -70),
                      child: Column(
                        children: [
                          Text(
                            'Forgot Password',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email to reset your password',
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
                                  controller: _emailCtrl,
                                  hintText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  onPressed: _onRequestReset,
                                  text: 'Send Reset Email',
                                  isLoading: authProvider.isLoading,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Back to Login",
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