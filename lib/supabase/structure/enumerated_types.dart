// Enumerated types from Supabase database schema
// These enums correspond to USER-DEFINED types in the database

/// Status of a certification request
enum CertificationStatus {
  draft,
  accepted,
  rejected;

  /// Convert from database string value
  static CertificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return CertificationStatus.draft;
      case 'accepted':
        return CertificationStatus.accepted;
      case 'rejected':
        return CertificationStatus.rejected;
      default:
        throw ArgumentError('Unknown CertificationStatus: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationStatus.draft:
        return 'Bozza';
      case CertificationStatus.accepted:
        return 'Accettata';
      case CertificationStatus.rejected:
        return 'Rifiutata';
    }
  }
}

/// Status of a legal entity registration
enum LegalEntityStatus {
  pending,
  approved,
  rejected;

  /// Convert from database string value
  static LegalEntityStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return LegalEntityStatus.pending;
      case 'approved':
        return LegalEntityStatus.approved;
      case 'rejected':
        return LegalEntityStatus.rejected;
      default:
        throw ArgumentError('Unknown LegalEntityStatus: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case LegalEntityStatus.pending:
        return 'In Attesa';
      case LegalEntityStatus.approved:
        return 'Approvata';
      case LegalEntityStatus.rejected:
        return 'Rifiutata';
    }
  }
}

/// User gender options
enum UserGender {
  male,
  female,
  other,
  preferNotToSay,
  nonBinary;

  /// Convert from database string value
  static UserGender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return UserGender.male;
      case 'female':
        return UserGender.female;
      case 'other':
        return UserGender.other;
      case 'prefer_not_to_say':
        return UserGender.preferNotToSay;
      case 'non_binary':
        return UserGender.nonBinary;
      default:
        throw ArgumentError('Unknown UserGender: $value');
    }
  }

  /// Convert to database string value
  String toDbString() {
    switch (this) {
      case UserGender.male:
        return 'male';
      case UserGender.female:
        return 'female';
      case UserGender.other:
        return 'other';
      case UserGender.preferNotToSay:
        return 'prefer_not_to_say';
      case UserGender.nonBinary:
        return 'non_binary';
    }
  }

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case UserGender.male:
        return 'Maschio';
      case UserGender.female:
        return 'Femmina';
      case UserGender.other:
        return 'Altro';
      case UserGender.preferNotToSay:
        return 'Preferisco non dirlo';
      case UserGender.nonBinary:
        return 'Non binario';
    }
  }
}

/// User type classification
enum UserType {
  user,
  legalEntity,
  certifier,
  admin;

  /// Convert from database string value
  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return UserType.user;
      case 'legal_entity':
        return UserType.legalEntity;
      case 'certifier':
        return UserType.certifier;
      case 'admin':
        return UserType.admin;
      default:
        throw ArgumentError('Unknown UserType: $value');
    }
  }

  /// Convert to database string value
  String toDbString() {
    switch (this) {
      case UserType.user:
        return 'user';
      case UserType.legalEntity:
        return 'legal_entity';
      case UserType.certifier:
        return 'certifier';
      case UserType.admin:
        return 'admin';
    }
  }

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case UserType.user:
        return 'Utente';
      case UserType.legalEntity:
        return 'Legal Entity';
      case UserType.certifier:
        return 'Certificatore';
      case UserType.admin:
        return 'Amministratore';
    }
  }
}

/// Who created the wallet
enum WalletCreatedBy {
  application,
  user;

  /// Convert from database string value
  static WalletCreatedBy fromString(String value) {
    switch (value.toLowerCase()) {
      case 'application':
        return WalletCreatedBy.application;
      case 'user':
        return WalletCreatedBy.user;
      default:
        throw ArgumentError('Unknown WalletCreatedBy: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case WalletCreatedBy.application:
        return 'Applicazione';
      case WalletCreatedBy.user:
        return 'Utente';
    }
  }
}