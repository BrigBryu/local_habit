import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/username_auth_service.dart';
import '../../core/auth/auth_wrapper.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../core/validation/validation_service.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!ValidationService.instance.canPerformWrite()) {
      _showSnackBar('Please wait before trying again', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use username auth service for consistent authentication
      final result = await UsernameAuthService.instance.signUp(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result.isSuccess) {
        _logger.i('Sign up successful - automatically signed in');
        _showSnackBar(
            'Account created and signed in successfully!', Colors.green);

        // Auth stream will handle navigation automatically
      } else {
        if (result.error?.contains('already exists') == true) {
          _showSnackBar(
              'This username is already taken. Please try a different one.',
              Colors.orange);
        } else {
          _showSnackBar(result.error ?? 'Sign up failed', Colors.red);
        }
      }
    } catch (e) {
      _logger.e('Sign up error', error: e);
      _showSnackBar('An unexpected error occurred', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _quickSignUpWithAutoIncrement() async {
    setState(() => _isLoading = true);

    try {
      // Find the next available username starting from user1
      for (int i = 1; i <= 100; i++) {
        final username = 'user$i';
        final result = await UsernameAuthService.instance.signUp(
          username,
          'q1234567',
        );

        if (result.isSuccess) {
          _logger.i('Quick sign up successful for $username');
          _showSnackBar(
              'Account created and signed in as $username!', Colors.green);

          // Auth stream will handle navigation automatically
          return;
        } else if (!result.error!.contains('already exists')) {
          // If it's not a "username exists" error, show the actual error
          _showSnackBar(
              'Failed to create account: ${result.error}', Colors.red);
          return;
        }
        // If username exists, try the next number
      }

      _showSnackBar('Could not find available username (tried user1-user100)',
          Colors.red);
    } catch (e) {
      _logger.e('Quick sign up error', error: e);
      _showSnackBar('An unexpected error occurred', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
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
        title: const Text('Sign Up'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Quick test button at the very top for visibility
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.primaryPurple, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🚀 QUICK TEST ACCOUNT',
                          style: TextStyle(
                            color: colors.primaryPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _quickSignUpWithAutoIncrement(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primaryPurple,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'CREATE USER1, USER2, ETC.',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logo or app name
                  Text(
                    'Join Habit Level Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                      final result = ValidationService.instance
                          .validateUsername(value ?? '');
                      return result.isValid ? null : result.errorMessage;
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
                      prefixIcon:
                          Icon(Icons.lock, color: colors.draculaComment),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: colors.draculaComment,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                          .hasMatch(value)) {
                        return 'Password must contain uppercase, lowercase, and number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: colors.draculaForeground),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
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
                      prefixIcon: Icon(Icons.lock_outline,
                          color: colors.draculaComment),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: colors.draculaComment,
                        ),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signUp(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Regular sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.draculaComment,
                        foregroundColor: colors.draculaBackground,
                      ),
                      child: const Text('Manual Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: colors.draculaComment),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()),
                          );
                        },
                        child: Text(
                          'Sign In',
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
      ),
    );
  }
}
