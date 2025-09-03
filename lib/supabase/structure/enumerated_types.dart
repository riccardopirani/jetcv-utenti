// Enumerated types from Supabase database schema
// These enums correspond to USER-DEFINED types in the database

/// Status of a certification request
enum CertificationStatus {
  draft,
  sent,
  closed;

  /// Convert from database string value
  static CertificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return CertificationStatus.draft;
      case 'sent':
        return CertificationStatus.sent;
      case 'closed':
        return CertificationStatus.closed;
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
      case CertificationStatus.sent:
        return 'Inviata';
      case CertificationStatus.closed:
        return 'Chiusa';
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

/// Category type for certifications
enum CertificationCategoryType {
  standard,
  custom;

  /// Convert from database string value
  static CertificationCategoryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'standard':
        return CertificationCategoryType.standard;
      case 'custom':
        return CertificationCategoryType.custom;
      default:
        throw ArgumentError('Unknown CertificationCategoryType: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationCategoryType.standard:
        return 'Standard';
      case CertificationCategoryType.custom:
        return 'Personalizzata';
    }
  }
}

/// Information scope for certifications
enum CertificationInformationScope {
  certification,
  certificationUser;

  /// Convert from database string value
  static CertificationInformationScope fromString(String value) {
    switch (value.toLowerCase()) {
      case 'certification':
        return CertificationInformationScope.certification;
      case 'certification_user':
        return CertificationInformationScope.certificationUser;
      default:
        throw ArgumentError('Unknown CertificationInformationScope: $value');
    }
  }

  /// Convert to database string value
  String toDbString() {
    switch (this) {
      case CertificationInformationScope.certification:
        return 'certification';
      case CertificationInformationScope.certificationUser:
        return 'certification_user';
    }
  }

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationInformationScope.certification:
        return 'Certificazione';
      case CertificationInformationScope.certificationUser:
        return 'Utente Certificazione';
    }
  }
}

/// Information type for certifications
enum CertificationInformationType {
  standard,
  custom;

  /// Convert from database string value
  static CertificationInformationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'standard':
        return CertificationInformationType.standard;
      case 'custom':
        return CertificationInformationType.custom;
      default:
        throw ArgumentError('Unknown CertificationInformationType: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationInformationType.standard:
        return 'Standard';
      case CertificationInformationType.custom:
        return 'Personalizzata';
    }
  }
}

/// Media acquisition type for certifications
enum CertificationMediaAcquisitionType {
  realtime,
  deferred;

  /// Convert from database string value
  static CertificationMediaAcquisitionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'realtime':
        return CertificationMediaAcquisitionType.realtime;
      case 'deferred':
        return CertificationMediaAcquisitionType.deferred;
      default:
        throw ArgumentError(
            'Unknown CertificationMediaAcquisitionType: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationMediaAcquisitionType.realtime:
        return 'Tempo reale';
      case CertificationMediaAcquisitionType.deferred:
        return 'Differito';
    }
  }
}

/// Media file type for certifications
enum CertificationMediaFileType {
  image,
  video,
  document;

  /// Convert from database string value
  static CertificationMediaFileType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return CertificationMediaFileType.image;
      case 'video':
        return CertificationMediaFileType.video;
      case 'document':
        return CertificationMediaFileType.document;
      default:
        throw ArgumentError('Unknown CertificationMediaFileType: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationMediaFileType.image:
        return 'Immagine';
      case CertificationMediaFileType.video:
        return 'Video';
      case CertificationMediaFileType.document:
        return 'Documento';
    }
  }
}

/// Status of a certification user
enum CertificationUserStatus {
  draft,
  pending,
  accepted,
  rejected;

  /// Convert from database string value
  static CertificationUserStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return CertificationUserStatus.draft;
      case 'pending':
        return CertificationUserStatus.pending;
      case 'accepted':
        return CertificationUserStatus.accepted;
      case 'rejected':
        return CertificationUserStatus.rejected;
      default:
        throw ArgumentError('Unknown CertificationUserStatus: $value');
    }
  }

  /// Convert to database string value
  String toDbString() => name;

  /// Get Italian display label
  String get displayLabel {
    switch (this) {
      case CertificationUserStatus.draft:
        return 'Bozza';
      case CertificationUserStatus.pending:
        return 'In attesa';
      case CertificationUserStatus.accepted:
        return 'Accettata';
      case CertificationUserStatus.rejected:
        return 'Rifiutata';
    }
  }
}
