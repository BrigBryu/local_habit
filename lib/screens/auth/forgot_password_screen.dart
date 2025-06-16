import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/flexible_theme_system.dart';
import '../../core/validation/validation_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!ValidationService.instance.canPerformWrite()) {
      _showSnackBar('Please wait before trying again', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.instance
          .resetPassword(_emailController.text.trim());

      if (result.isSuccess) {
        _logger.i('Password reset email sent');
        setState(() => _emailSent = true);
        _showSnackBar(
            'Password reset instructions sent to your email', Colors.green);
      } else {
        _showSnackBar(
            result.error ?? 'Failed to send password reset email', Colors.red);
      }
    } catch (e) {
      _logger.e('Password reset error', error: e);
      _showSnackBar('An unexpected error occurred', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (!ValidationService.instance.canPerformWrite()) {
      _showSnackBar('Please wait before trying again', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.instance
          .resendVerification(_emailController.text.trim());

      if (result.isSuccess) {
        _showSnackBar('Verification email resent', Colors.green);
      } else {
        _showSnackBar(result.error ?? 'Failed to resend email', Colors.red);
      }
    } catch (e) {
      _logger.e('Resend email error', error: e);
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
        title: const Text('Reset Password'),
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
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: colors.primaryPurple,
                ),
                const SizedBox(height: 24),

                Text(
                  _emailSent ? 'Check Your Email' : 'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.draculaForeground,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _emailSent
                      ? 'We\'ve sent password reset instructions to your email address.'
                      : 'Enter your email address and we\'ll send you instructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.draculaComment,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_emailSent) ...[
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _resetPassword(),
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
                  const SizedBox(height: 24),

                  // Reset password button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send Reset Instructions'),
                    ),
                  ),
                ] else ...[
                  // Email sent confirmation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.completedBackground.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: colors.completedBackground.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mark_email_read,
                          size: 48,
                          color: colors.completedBackground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email sent to:\n${_emailController.text}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.draculaForeground,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend button
                  TextButton(
                    onPressed: _isLoading ? null : _resendEmail,
                    child: Text(
                      'Resend Email',
                      style: TextStyle(color: colors.primaryPurple),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Back to sign in
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back to Sign In',
                    style: TextStyle(color: colors.draculaComment),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
