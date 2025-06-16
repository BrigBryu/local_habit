import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/username_auth_service.dart';
import '../../core/auth/auth_wrapper.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../providers/repository_init_provider.dart';
import 'username_sign_up_screen.dart';

class UsernameSignInScreen extends ConsumerStatefulWidget {
  const UsernameSignInScreen({super.key});

  @override
  ConsumerState<UsernameSignInScreen> createState() => _UsernameSignInScreenState();
}

class _UsernameSignInScreenState extends ConsumerState<UsernameSignInScreen> {
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

    setState(() => _isLoading = true);

    try {
      final result = await UsernameAuthService.instance.signIn(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result.isSuccess) {
        _logger.i('Sign in successful');
        // Update auth state to trigger navigation
        ref.read(authStateProvider.notifier).state = true;
        
        // Invalidate the repository provider to reinitialize with signed-in user
        ref.invalidate(repositoryProvider);
        _logger.i('Repository provider invalidated for signed-in user');
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
                const SizedBox(height: 8),
                Text(
                  'Track habits, level up together',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.draculaComment,
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
                    hintText: 'Enter your username',
                    hintStyle: TextStyle(
                        color: colors.draculaComment.withOpacity(0.7)),
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
                    prefixIcon: Icon(Icons.person, color: colors.draculaComment),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters long';
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
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                        color: colors.draculaComment.withOpacity(0.7)),
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
                      return 'Please enter your password';
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
                              builder: (context) => const UsernameSignUpScreen()),
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