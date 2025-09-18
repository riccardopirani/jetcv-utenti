import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for password-related operations
class PasswordService {
  static final _client = SupabaseConfig.client;

  /// Update user password by verifying old password and setting new one
  /// This method requires the user to be authenticated and know their current password
  static Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    Map<String, String>? localizedMessages,
  }) async {
    try {
      debugPrint('🔐 PasswordService: Starting password update for: $email');

      // First, verify the old password by attempting to sign in
      try {
        final signInResponse = await _client.auth.signInWithPassword(
          email: email,
          password: oldPassword,
        );

        if (signInResponse.user == null) {
          return {
            'success': false,
            'error': localizedMessages?['authenticationFailed'] ?? 'Authentication failed',
            'message': localizedMessages?['oldPasswordIncorrect'] ?? 'Old password is incorrect',
          };
        }

        debugPrint('✅ PasswordService: Old password verified successfully');

        // Now update the password
        final updateResponse = await _client.auth.updateUser(
          UserAttributes(password: newPassword),
        );

        if (updateResponse.user != null) {
          debugPrint('✅ PasswordService: Password updated successfully');

          // Sign out the user so they need to log in again with new password
          await _client.auth.signOut();

          return {
            'success': true,
            'message': localizedMessages?['passwordUpdateSuccess'] ?? 'Password updated successfully. Please log in with your new password.',
          };
        } else {
          return {
            'success': false,
            'error': localizedMessages?['updateFailed'] ?? 'Update failed',
            'message': localizedMessages?['passwordUpdateFailed'] ?? 'Failed to update password',
          };
        }
      } on AuthException catch (e) {
        debugPrint('❌ PasswordService: Auth error: ${e.message}');
        
        if (e.message.contains('Invalid login credentials') ||
            e.message.contains('Invalid email or password')) {
          return {
            'success': false,
            'error': localizedMessages?['invalidCredentials'] ?? 'Invalid credentials',
            'message': localizedMessages?['oldPasswordIncorrect'] ?? 'Old password is incorrect',
          };
        }
        
        return {
          'success': false,
          'error': localizedMessages?['authenticationError'] ?? 'Authentication error',
          'message': e.message,
        };
      }
    } catch (e) {
      debugPrint('❌ PasswordService: Unexpected error: $e');
      return {
        'success': false,
        'error': localizedMessages?['unexpectedError'] ?? 'Unexpected error',
        'message': '${localizedMessages?['unexpectedError'] ?? 'An unexpected error occurred'}: $e',
      };
    }
  }

  /// Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    if (password.length < 6) {
      return {
        'valid': false,
        'error': 'Password must be at least 6 characters long',
      };
    }

    // Add more password strength checks if needed
    return {
      'valid': true,
      'message': 'Password is valid',
    };
  }

  /// Check if passwords match
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
