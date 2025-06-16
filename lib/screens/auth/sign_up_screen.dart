import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/simple_auth_service.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../core/validation/validation_service.dart';
import 'sign_in_screen.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
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
      // Use simple auth service for immediate sign-up and sign-in
      final result = await SimpleAuthService.instance.signUpAndSignIn(
        _emailController.text.trim(),
        _passwordController.text,
        _displayNameController.text.trim(),
      );

      if (result.isSuccess) {
        _logger.i('Sign up and sign in successful - no email verification needed');
        _showSnackBar('Account created and signed in!', Colors.green);
        // AuthWrapper will automatically handle navigation to main app
      } else {
        if (result.error?.contains('already registered') == true) {
          _showSnackBar(
              'This email is already registered. Please sign in instead.',
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Logo or app name
                  Text(
                    'Join Habit Level Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Display name field
                  TextFormField(
                    controller: _displayNameController,
                    style: TextStyle(color: colors.draculaForeground),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
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

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: colors.draculaForeground),
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                          Icon(Icons.email, color: colors.draculaComment),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
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

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 32),

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
