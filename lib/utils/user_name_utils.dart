import 'package:flutter/material.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';

/// Utility class for handling user display names with consistent logic
class UserNameUtils {
  /// Capitalize the first letter of each word
  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get user display name with proper priority and capitalization
  static String getUserDisplayName(BuildContext context, UserModel? user) {
    final supabaseUser = SupabaseAuth.currentUser;

    // Priority 1: firstName + lastName (if both present)
    final firstName = user?.firstName?.trim();
    final lastName = user?.lastName?.trim();
    if (firstName != null &&
        firstName.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty) {
      return '${_capitalizeWords(firstName)} ${_capitalizeWords(lastName)}';
    }

    // Priority 2: fullName (if present)
    final fullName = user?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return _capitalizeWords(fullName);
    }

    // Priority 3: firstName only (if present)
    if (firstName != null && firstName.isNotEmpty) {
      return _capitalizeWords(firstName);
    }

    // Priority 4: lastName only (if present)
    if (lastName != null && lastName.isNotEmpty) {
      return _capitalizeWords(lastName);
    }

    // Priority 5: Supabase metadata full_name
    final supabaseFullName =
        supabaseUser?.userMetadata?['full_name']?.toString().trim();
    if (supabaseFullName != null && supabaseFullName.isNotEmpty) {
      return _capitalizeWords(supabaseFullName);
    }

    // Priority 6: Email username part
    final email = supabaseUser?.email;
    if (email != null && email.isNotEmpty) {
      final emailPart = email.split('@')[0].trim();
      if (emailPart.isNotEmpty) {
        return _capitalizeWords(emailPart);
      }
    }

    // Final fallback: localized "User"
    return AppLocalizations.of(context)!.user;
  }

  /// Get the first letter of the display name for avatars
  static String getInitial(BuildContext context, UserModel? user) {
    final displayName = getUserDisplayName(context, user);
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }
}
