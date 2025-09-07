import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';
import 'package:jetcv__utenti/utils/database_helpers.dart';

/// Examples of how to use enums with Italian display labels
class EnumExamples {
  /// Example usage showing database values vs display labels
  static void demonstrateUsage() {
    // Example 1: UserGender
    const gender = UserGender.male;
    print('Database value: ${gender.toDbString()}'); // "male"
    print('Display label: ${gender.displayLabel}'); // "Maschio"
    print(
        'Helper method: ${DatabaseHelpers.getDisplayText(gender)}'); // "Maschio"

    // Example 2: UserType
    const userType = UserType.legalEntity;
    print('Database value: ${userType.toDbString()}'); // "legal_entity"
    print('Display label: ${userType.displayLabel}'); // "Ente Giuridico"

    // Example 3: CertificationStatus
    const status = CertificationStatus.sent;
    print('Database value: ${status.toDbString()}'); // "sent"
    print('Display label: ${status.displayLabel}'); // "Inviata"

    // Example 4: Parsing from database
    const dbValue = 'prefer_not_to_say';
    final parsedGender = UserGender.fromString(dbValue);
    print(
        'Parsed from DB: ${parsedGender.displayLabel}'); // "Preferisco non dirlo"
  }

  /// Get all display labels for UI dropdowns
  static List<String> getAllGenderLabels() {
    return UserGender.values.map((e) => e.displayLabel).toList();
  }

  static List<String> getAllUserTypeLabels() {
    return UserType.values.map((e) => e.displayLabel).toList();
  }

  static List<String> getAllCertificationStatusLabels() {
    return CertificationStatus.values.map((e) => e.displayLabel).toList();
  }

  static List<String> getAllLegalEntityStatusLabels() {
    return LegalEntityStatus.values.map((e) => e.displayLabel).toList();
  }

  /// Helper to create Map for dropdowns (value -> label)
  static Map<String, String> getGenderOptions() {
    return Map.fromEntries(
        UserGender.values.map((e) => MapEntry(e.toDbString(), e.displayLabel)));
  }

  static Map<String, String> getUserTypeOptions() {
    return Map.fromEntries(
        UserType.values.map((e) => MapEntry(e.toDbString(), e.displayLabel)));
  }
}
