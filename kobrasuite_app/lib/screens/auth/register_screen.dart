import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/general/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/rounded_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  Future<void> _onRegister() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    final success = await authProvider.register(
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _passwordCtrl.text.trim(),
      _confirmPasswordCtrl.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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
                    const Icon(Icons.app_registration, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Form(
                        key: _formKey,
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
                              hintText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                            ),
                            const SizedBox(height: 16),
                            RoundedTextField(
                              controller: _emailCtrl,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email),
                            ),
                            const SizedBox(height: 16),
                            RoundedTextField(
                              controller: _phoneCtrl,
                              hintText: 'Phone',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            const SizedBox(height: 16),
                            RoundedTextField(
                              controller: _passwordCtrl,
                              hintText: 'Password',
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock),
                            ),
                            const SizedBox(height: 16),
                            RoundedTextField(
                              controller: _confirmPasswordCtrl,
                              hintText: 'Confirm Password',
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_reset),
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              onPressed: _onRegister,
                              text: 'Register',
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
                                'Go to Login',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
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