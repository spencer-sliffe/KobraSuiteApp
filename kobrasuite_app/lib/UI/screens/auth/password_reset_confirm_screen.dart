import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/general/auth_provider.dart';
import 'buttons/primary_button.dart';
import 'inputs/rounded_text_field.dart';
import 'login_screen.dart';

class PasswordResetConfirmScreen extends StatefulWidget {
  const PasswordResetConfirmScreen({super.key});

  @override
  PasswordResetConfirmScreenState createState() => PasswordResetConfirmScreenState();
}

class PasswordResetConfirmScreenState extends State<PasswordResetConfirmScreen> {
  final _uidCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _uidCtrl.dispose();
    _tokenCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onResetConfirm() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    if (_newPasswordCtrl.text.trim() != _confirmPasswordCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    final success = await authProvider.passwordResetConfirm(
      _uidCtrl.text.trim(),
      _tokenCtrl.text.trim(),
      _newPasswordCtrl.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password successfully reset')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                            'Reset Your Password',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter User ID, token, and a new password',
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
                                  controller: _uidCtrl,
                                  hintText: 'User ID',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                const SizedBox(height: 16),
                                RoundedTextField(
                                  controller: _tokenCtrl,
                                  hintText: 'Token',
                                  prefixIcon: const Icon(Icons.security),
                                ),
                                const SizedBox(height: 16),
                                RoundedTextField(
                                  controller: _newPasswordCtrl,
                                  hintText: 'New Password',
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                const SizedBox(height: 16),
                                RoundedTextField(
                                  controller: _confirmPasswordCtrl,
                                  hintText: 'Confirm New Password',
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_reset),
                                ),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  onPressed: _onResetConfirm,
                                  text: 'Reset Password',
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