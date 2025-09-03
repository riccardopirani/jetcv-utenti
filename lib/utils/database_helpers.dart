import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Helper utilities for database operations and data handling
class DatabaseHelpers {
  /// Parse enum values safely with fallbacks
  static T? parseEnum<T>(String? value, T Function(String) parser) {
    if (value == null || value.isEmpty) return null;
    try {
      return parser(value);
    } catch (e) {
      return null;
    }
  }

  /// Parse DateTime safely
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Parse Date only (no time) safely
  static DateTime? parseDateOnly(dynamic value) {
    final dateTime = parseDateTime(value);
    if (dateTime == null) return null;
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Format DateTime to ISO string or null
  static String? formatDateTime(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  /// Format Date only (no time) to string
  static String? formatDateOnly(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String().split('T')[0];
  }

  /// Clean and trim text input
  static String? cleanText(String? text) {
    if (text == null) return null;
    final cleaned = text.trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number (basic check)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    // Remove spaces and special characters for validation
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Validate UUID format
  static bool isValidUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return false;
    return RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$')
        .hasMatch(uuid);
  }

  /// Get display text for enums (Italian labels)
  static String getDisplayText(dynamic enumValue) {
    if (enumValue == null) return 'N/A';

    // Use the displayLabel property if available
    if (enumValue is UserGender) return enumValue.displayLabel;
    if (enumValue is UserType) return enumValue.displayLabel;
    if (enumValue is CertificationStatus) return enumValue.displayLabel;
    if (enumValue is LegalEntityStatus) return enumValue.displayLabel;
    if (enumValue is WalletCreatedBy) return enumValue.displayLabel;

    // Fallback to enum name
    return enumValue.toString().split('.').last;
  }

  /// Get status color based on enum value
  static String getStatusColor(dynamic enumValue) {
    if (enumValue == null) return 'grey';

    switch (enumValue.runtimeType) {
      case CertificationStatus:
        final status = enumValue as CertificationStatus;
        switch (status) {
          case CertificationStatus.draft:
            return 'orange';
          case CertificationStatus.accepted:
            return 'green';
          case CertificationStatus.rejected:
            return 'red';
        }
      case LegalEntityStatus:
        final status = enumValue as LegalEntityStatus;
        switch (status) {
          case LegalEntityStatus.pending:
            return 'orange';
          case LegalEntityStatus.approved:
            return 'green';
          case LegalEntityStatus.rejected:
            return 'red';
        }
      default:
        return 'blue';
    }
  }

  /// Convert map keys to match database column names (with quotes)
  static Map<String, dynamic> toDatabaseKeys(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      result['"${entry.key}"'] = entry.value;
    }
    return result;
  }

  /// Remove null values from map
  static Map<String, dynamic> removeNullValues(Map<String, dynamic> map) {
    return Map.fromEntries(
      map.entries.where((entry) => entry.value != null),
    );
  }
}
