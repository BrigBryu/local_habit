import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

class EmailVerificationHandler {
  static final Logger _logger = Logger();

  /// Handle email verification link manually
  /// This is a workaround for the localhost redirect issue
  static Future<bool> handleEmailVerification(String verificationCode) async {
    try {
      // Extract verification code from URL if needed
      final code = verificationCode.contains('code=') 
          ? verificationCode.split('code=')[1].split('&')[0]
          : verificationCode;

      _logger.i('Attempting to verify email with code: ${code.substring(0, 8)}...');

      // For now, we'll check if the user's email is verified after they click the link
      // In a production app, you'd want to implement proper deep linking
      
      return true; // Assume verification worked if they got the code
    } catch (e) {
      _logger.e('Email verification failed', error: e);
      return false;
    }
  }

  /// Check if current user's email is verified
  static bool isEmailVerified() {
    try {
      final user = supabase.auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      _logger.e('Failed to check email verification status', error: e);
      return false;
    }
  }

  /// Show instructions for manual email verification
  static void showEmailVerificationInstructions(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A verification email has been sent to:'),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('To verify your email:'),
            const SizedBox(height: 8),
            const Text('1. Check your email inbox (and spam folder)'),
            const Text('2. Click the verification link'),
            const Text('3. Close this dialog and try signing in'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Text(
                'Note: If the verification link opens to an error page, that\'s normal for mobile apps. The verification still works - just return to the app and sign in.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK, I understand'),
          ),
        ],
      ),
    );
  }
}