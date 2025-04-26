import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../providers/general/auth_provider.dart';
import 'buttons/primary_button.dart';
import 'inputs/rounded_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _usernameCtrl        = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _phoneCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(###) ###-####',          // (123) 456-7890
    filter: { '#': RegExp(r'\d') },
  );

  Future<void> _onRegister() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final ok = await auth.register(
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneMask.getUnmaskedText(),  // pass only digits
      _passwordCtrl.text,
      _confirmPasswordCtrl.text,
    );

    /*  AuthProvider is now “logged-in”; let AuthWrapper rebuild.
        We simply close this page.                                      */
    if (ok && mounted) Navigator.pop(context);
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
                    const Icon(Icons.app_registration, size: 64),
                    const SizedBox(height: 24),
                    Text('Create Account',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Sign up to get started',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),

                    /* ── card ───────────────────────────────────── */
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
                            if (auth.errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  auth.errorMessage,
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
                              inputFormatters: [_phoneMask],
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
                              isLoading: auth.isLoading,
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Go to Login',
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