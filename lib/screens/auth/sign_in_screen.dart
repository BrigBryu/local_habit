import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/username_auth_service.dart';
import '../../core/auth/auth_wrapper.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../core/validation/validation_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    if (!ValidationService.instance.canPerformWrite()) {
      _showSnackBar('Please wait before trying again', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await UsernameAuthService.instance.signIn(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result.isSuccess) {
        _logger.i('Sign in successful');
        _showSnackBar('Signed in successfully!', Colors.green);

        // Auth stream will handle navigation automatically
      } else {
        _showSnackBar(result.error ?? 'Sign in failed', Colors.red);
      }
    } catch (e) {
      _logger.e('Sign in error', error: e);
      _showSnackBar('An unexpected error occurred', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _quickSignInWithAutoIncrement() async {
    setState(() => _isLoading = true);

    try {
      // Try to find an existing user starting from user1
      String? foundUsername;
      for (int i = 1; i <= 100; i++) {
        final username = 'user$i';
        final result = await UsernameAuthService.instance.signIn(
          username,
          'q1234567',
        );

        if (result.isSuccess) {
          foundUsername = username;
          break;
        }
      }

      if (foundUsername != null) {
        _logger.i('Quick sign in successful for $foundUsername');
        _showSnackBar('Signed in as $foundUsername!', Colors.green);

        // Auth stream will handle navigation automatically
      } else {
        // No existing users found, create user1
        await _createNewUser();
      }
    } catch (e) {
      _logger.e('Quick sign in error', error: e);
      _showSnackBar('An unexpected error occurred', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createNewUser() async {
    // Find the next available username starting from user1
    for (int i = 1; i <= 100; i++) {
      final username = 'user$i';
      final signUpResult = await UsernameAuthService.instance.signUp(
        username,
        'q1234567',
      );

      if (signUpResult.isSuccess) {
        _logger.i('Quick account created and signed in for $username');
        _showSnackBar(
            'Created account and signed in as $username!', Colors.green);

        // Auth stream will handle navigation automatically
        return;
      } else if (!signUpResult.error!.contains('already exists')) {
        // If it's not a "username exists" error, show the actual error
        _showSnackBar(
            'Failed to create account: ${signUpResult.error}', Colors.red);
        return;
      }
      // If username exists, try the next number
    }

    _showSnackBar(
        'Could not find available username (tried user1-user100)', Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;

    return Scaffold(
      backgroundColor: colors.backgroundDark,
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or app name
                Text(
                  'Habit Level Up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 48),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: colors.draculaForeground),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: colors.draculaComment),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.draculaComment),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.primaryPurple),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor: colors.cardBackgroundDark,
                    prefixIcon:
                        Icon(Icons.person, color: colors.draculaComment),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: colors.draculaForeground),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: colors.draculaComment),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.draculaComment),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.primaryPurple),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor: colors.cardBackgroundDark,
                    prefixIcon: Icon(Icons.lock, color: colors.draculaComment),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colors.draculaComment,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot password
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: colors.primaryPurple),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick test sign-in buttons
                Text(
                  'Quick Test Sign-In',
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _quickSignInWithAutoIncrement(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.draculaComment,
                          foregroundColor: colors.draculaBackground,
                        ),
                        child: const Text('Quick Sign In'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: colors.draculaComment),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: colors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
