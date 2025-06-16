import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../core/validation/validation_service.dart';
import '../../core/network/supabase_client.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.trim().length < 1) return;

    setState(() => _isCheckingUsername = true);

    try {
      // Check if username exists in profiles table
      final response = await supabase
          .from('profiles')
          .select('display_name')
          .ilike('display_name', username.trim())
          .limit(1);

      if (response.isNotEmpty) {
        setState(() => _usernameError = 'Username already taken');
      } else {
        setState(() => _usernameError = null);
      }
    } catch (e) {
      _logger.e('Error checking username availability', error: e);
      setState(() => _usernameError = 'Unable to check username availability');
    } finally {
      setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usernameError != null) {
      _showSnackBar('Please choose a different username', Colors.red);
      return;
    }

    if (!ValidationService.instance.canPerformWrite()) {
      _showSnackBar('Please wait before trying again', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar('Not authenticated', Colors.red);
        return;
      }

      final username =
          ValidationService.instance.sanitizeUserText(_usernameController.text);

      // Update the user's profile with display_name
      await supabase.from('profiles').upsert({
        'id': userId,
        'display_name': username,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _logger.i('Username set successfully: $username');
      _showSnackBar('Username set successfully!', Colors.green);

      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _logger.e('Failed to set username', error: e);

      if (e.toString().contains('duplicate key value')) {
        _showSnackBar('Username already taken. Please choose a different one.',
            Colors.red);
      } else {
        _showSnackBar('Failed to set username. Please try again.', Colors.red);
      }
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

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: colors.backgroundDark,
        appBar: AppBar(
          title: const Text('Choose Username'),
          backgroundColor: colors.draculaBackground,
          foregroundColor: colors.draculaForeground,
          automaticallyImplyLeading: false, // Remove back button
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add,
                    size: 64,
                    color: colors.primaryPurple,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Welcome to Habit Level Up!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.draculaForeground,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Please choose a username to get started. This will be visible to your partners.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.draculaComment,
                      fontSize: 16,
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
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usernameError == null &&
                                  _usernameController.text.isNotEmpty
                              ? Icon(Icons.check_circle,
                                  color: colors.completedBackground)
                              : null,
                      errorText: _usernameError,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      // Debounced username check
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (value.trim() == _usernameController.text.trim()) {
                          _checkUsernameAvailability(value);
                        }
                      });
                    },
                    onFieldSubmitted: (_) => _saveUsername(),
                    validator: (value) {
                      final result = ValidationService.instance
                          .validateUsername(value ?? '');
                      return result.isValid ? null : result.errorMessage;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_isLoading ||
                              _isCheckingUsername ||
                              _usernameError != null)
                          ? null
                          : _saveUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: colors.primaryPurple.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Username Requirements:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 1-32 characters\n• No leading/trailing spaces\n• Letters, numbers, spaces, hyphens, underscores',
                          style: TextStyle(color: colors.draculaComment),
                        ),
                      ],
                    ),
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
