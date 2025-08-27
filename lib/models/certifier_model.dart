/// Certifier model representing the certifier table
class CertifierModel {
  final String idCertifier;
  final String? idCertifierHash;
  final String? idUser;
  final String? idLegalEntity;
  final bool? active;
  final String? roleCompany;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertifierModel({
    required this.idCertifier,
    this.idCertifierHash,
    this.idUser,
    this.idLegalEntity,
    this.active,
    this.roleCompany,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create CertifierModel from JSON/Map
  factory CertifierModel.fromJson(Map<String, dynamic> json) => CertifierModel(
    idCertifier: json['idCertifier'] as String,
    idCertifierHash: json['idCertifierHash'] as String?,
    idUser: json['idUser'] as String?,
    idLegalEntity: json['idLegalEntity'] as String?,
    active: json['active'] as bool?,
    roleCompany: json['roleCompany'] as String?,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  /// Convert CertifierModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'idCertifier': idCertifier,
    'idCertifierHash': idCertifierHash,
    'idUser': idUser,
    'idLegalEntity': idLegalEntity,
    'active': active,
    'roleCompany': roleCompany,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Create copy with updated fields
  CertifierModel copyWith({
    String? idCertifierHash,
    String? idUser,
    String? idLegalEntity,
    bool? active,
    String? roleCompany,
    DateTime? updatedAt,
  }) => CertifierModel(
    idCertifier: idCertifier,
    idCertifierHash: idCertifierHash ?? this.idCertifierHash,
    idUser: idUser ?? this.idUser,
    idLegalEntity: idLegalEntity ?? this.idLegalEntity,
    active: active ?? this.active,
    roleCompany: roleCompany ?? this.roleCompany,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  String toString() => 'CertifierModel(idCertifier: $idCertifier, roleCompany: $roleCompany, active: $active)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is CertifierModel &&
    runtimeType == other.runtimeType &&
    idCertifier == other.idCertifier;

  @override
  int get hashCode => idCertifier.hashCode;
}