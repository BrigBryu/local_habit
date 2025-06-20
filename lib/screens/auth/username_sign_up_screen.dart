import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/username_auth_service.dart';
import '../../core/auth/auth_wrapper.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../providers/repository_init_provider.dart';
import '../../providers/habits_provider.dart';
import 'username_sign_in_screen.dart';

class UsernameSignUpScreen extends ConsumerStatefulWidget {
  const UsernameSignUpScreen({super.key});

  @override
  ConsumerState<UsernameSignUpScreen> createState() =>
      _UsernameSignUpScreenState();
}

class _UsernameSignUpScreenState extends ConsumerState<UsernameSignUpScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      _logger.i('Regular sign up attempt for username: $username');

      final result = await UsernameAuthService.instance
          .signUp(username, _passwordController.text);

      if (result.isSuccess) {
        final currentUserId = UsernameAuthService.instance.getCurrentUserId();
        final isAuthenticated = UsernameAuthService.instance.isAuthenticated;

        _logger.i(
            'Sign up successful for $username (ID: $currentUserId, authenticated: $isAuthenticated)');
        _showSnackBar(
            'Account created and signed in successfully!', Colors.green);

        // Reset stream listener and force refresh auth state to trigger navigation
        ref.read(authStateNotifierProvider.notifier).resetStreamListener();
        
        // Invalidate repository providers to refresh for new user context
        ref.invalidate(repositoryProvider);
        ref.invalidate(ownHabitsProvider);
        
        // Add a small delay and refresh again to ensure state propagation
        await Future.delayed(const Duration(milliseconds: 200));
        ref.read(authStateNotifierProvider.notifier).refresh();
      } else {
        _logger.e('Sign up failed for $username: ${result.error}');
        _showSnackBar(result.error ?? 'Please try again', Colors.red);
      }
    } catch (e) {
      _logger.e('Sign up error', error: e);
      _showSnackBar('Please try again', Colors.red);
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
      for (var i = 1; i <= 100; ++i) {
        final username = 'user$i';
        _logger.i('Attempting to create account: $username');

        final result =
            await UsernameAuthService.instance.signUp(username, 'q1234567');

        if (result.isSuccess) {
          final currentUserId = UsernameAuthService.instance.getCurrentUserId();
          final isAuthenticated = UsernameAuthService.instance.isAuthenticated;

          _logger.i(
              'Quick sign up successful for $username (ID: $currentUserId, authenticated: $isAuthenticated)');
          _showSnackBar(
              'Account created and signed in as $username!', Colors.green);

          // Reset stream listener and force refresh auth state to trigger navigation
          ref.read(authStateNotifierProvider.notifier).resetStreamListener();
          
          // Invalidate repository providers to refresh for new user context
          ref.invalidate(repositoryProvider);
          ref.invalidate(ownHabitsProvider);
          
          // Add a small delay and refresh again to ensure state propagation
          await Future.delayed(const Duration(milliseconds: 200));
          ref.read(authStateNotifierProvider.notifier).refresh();
          return;
        }

        // Check if this was a "username exists" error
        if (result.error?.toLowerCase().contains('exists') == true) {
          _logger.i('Username $username already exists, trying next...');
          continue;
        }

        // Non-existence error - show and stop
        _logger.e('Account creation failed for $username: ${result.error}');
        _showSnackBar('Please try again', Colors.red);
        return;
      }

      // Exhausted all usernames
      _logger.w('All test usernames user1-user100 are taken');
      _showSnackBar('All test usernames taken', Colors.amber);
    } catch (e) {
      _logger.e('Quick sign up error', error: e);
      _showSnackBar('Please try again', Colors.red);
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
                  'Create Account :)',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the habit tracking community',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.draculaComment,
                  ),
                ),
                const SizedBox(height: 32),

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

                // Username field
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: colors.draculaForeground),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: colors.draculaComment),
                    hintText: 'Choose a unique username',
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
                    prefixIcon:
                        Icon(Icons.person, color: colors.draculaComment),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Username must be less than 20 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Username can only contain letters, numbers, and underscores';
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
                    hintText: 'Enter a secure password',
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
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
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
                    hintText: 'Confirm your password',
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
                    prefixIcon:
                        Icon(Icons.lock_outline, color: colors.draculaComment),
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
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: colors.draculaComment),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UsernameSignInScreen()),
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
    );
  }
}
