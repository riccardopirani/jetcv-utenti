/// Certifier model representing the certifier table
class CertifierModel {
  final String idCertifier;
  final String idCertifierHash;
  final String idLegalEntity;
  final String? idUser;
  final bool active;
  final String? role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invitationToken;
  final bool? kycPassed;
  final String? idKycAttempt;

  CertifierModel({
    required this.idCertifier,
    required this.idCertifierHash,
    required this.idLegalEntity,
    this.idUser,
    this.active = true,
    this.role,
    required this.createdAt,
    this.updatedAt,
    this.invitationToken,
    this.kycPassed,
    this.idKycAttempt,
  });

  /// Create CertifierModel from JSON/Map
  factory CertifierModel.fromJson(Map<String, dynamic> json) => CertifierModel(
        idCertifier: json['id_certifier'] as String,
        idCertifierHash: json['id_certifier_hash'] as String,
        idLegalEntity: json['id_legal_entity'] as String,
        idUser: json['id_user'] as String?,
        active: json['active'] as bool? ?? true,
        role: json['role'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        invitationToken: json['invitation_token'] as String?,
        kycPassed: json['kyc_passed'] as bool?,
        idKycAttempt: json['id_kyc_attempt'] as String?,
      );

  /// Convert CertifierModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certifier': idCertifier,
        'id_certifier_hash': idCertifierHash,
        'id_legal_entity': idLegalEntity,
        'id_user': idUser,
        'active': active,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'invitation_token': invitationToken,
        'kyc_passed': kycPassed,
        'id_kyc_attempt': idKycAttempt,
      };

  /// Create copy with updated fields
  CertifierModel copyWith({
    String? idUser,
    bool? active,
    String? role,
    DateTime? updatedAt,
    String? invitationToken,
    bool? kycPassed,
    String? idKycAttempt,
  }) =>
      CertifierModel(
        idCertifier: idCertifier,
        idCertifierHash: idCertifierHash,
        idLegalEntity: idLegalEntity,
        idUser: idUser ?? this.idUser,
        active: active ?? this.active,
        role: role ?? this.role,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        invitationToken: invitationToken ?? this.invitationToken,
        kycPassed: kycPassed ?? this.kycPassed,
        idKycAttempt: idKycAttempt ?? this.idKycAttempt,
      );

  @override
  String toString() =>
      'CertifierModel(idCertifier: $idCertifier, role: $role, active: $active)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertifierModel &&
          runtimeType == other.runtimeType &&
          idCertifier == other.idCertifier;

  @override
  int get hashCode => idCertifier.hashCode;
}
