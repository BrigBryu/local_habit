import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/flexible_theme_system.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    required this.email,
    super.key,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final Logger _logger = Logger();
  bool _isResending = false;

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);

    try {
      final result = await AuthService.instance.resendVerification(widget.email);
      
      if (result.isSuccess) {
        _showSnackBar('Verification email resent successfully', Colors.green);
      } else {
        _showSnackBar(result.error ?? 'Failed to resend email', Colors.red);
      }
    } catch (e) {
      _logger.e('Failed to resend verification', error: e);
      _showSnackBar('An error occurred', Colors.red);
    } finally {
      setState(() => _isResending = false);
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
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email verification icon
              Icon(
                Icons.mark_email_unread,
                size: 80,
                color: colors.primaryPurple,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.draculaForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We sent a verification link to:',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaComment,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email address
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primaryPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'To complete your account setup:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.draculaForeground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Check your email inbox (and spam folder)\n'
                      '2. Click the verification link in the email\n'
                      '3. Return to the app and sign in',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.draculaComment,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Resend button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isResending ? null : _resendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isResending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Resend Verification Email'),
                ),
              ),
              const SizedBox(height: 16),

              // Back to sign in
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: colors.primaryPurple,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}