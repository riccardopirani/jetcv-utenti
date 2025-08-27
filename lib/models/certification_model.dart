import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification model representing the certification table
class CertificationModel {
  final String idCertification;
  final String idCertificationHash;
  final String idUser;
  final String idCertifier;
  final String idLegalEntity;
  final CertificationStatus status;
  final DateTime? statusUpdatedAtByUser;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificationModel({
    required this.idCertification,
    required this.idCertificationHash,
    required this.idUser,
    required this.idCertifier,
    required this.idLegalEntity,
    this.status = CertificationStatus.draft,
    this.statusUpdatedAtByUser,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create CertificationModel from JSON/Map
  factory CertificationModel.fromJson(Map<String, dynamic> json) => CertificationModel(
    idCertification: json['idCertification'] as String,
    idCertificationHash: json['idCertificationHash'] as String,
    idUser: json['idUser'] as String,
    idCertifier: json['idCertifier'] as String,
    idLegalEntity: json['idLegalEntity'] as String,
    status: json['status'] != null ? CertificationStatus.fromString(json['status']) : CertificationStatus.draft,
    statusUpdatedAtByUser: json['statusUpdatedAtByUser'] != null ? DateTime.parse(json['statusUpdatedAtByUser']) : null,
    rejectionReason: json['rejectionReason'] as String?,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  /// Convert CertificationModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'idCertification': idCertification,
    'idCertificationHash': idCertificationHash,
    'idUser': idUser,
    'idCertifier': idCertifier,
    'idLegalEntity': idLegalEntity,
    'status': status.toDbString(),
    'statusUpdatedAtByUser': statusUpdatedAtByUser?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Create copy with updated fields
  CertificationModel copyWith({
    CertificationStatus? status,
    DateTime? statusUpdatedAtByUser,
    String? rejectionReason,
    DateTime? updatedAt,
  }) => CertificationModel(
    idCertification: idCertification,
    idCertificationHash: idCertificationHash,
    idUser: idUser,
    idCertifier: idCertifier,
    idLegalEntity: idLegalEntity,
    status: status ?? this.status,
    statusUpdatedAtByUser: statusUpdatedAtByUser ?? this.statusUpdatedAtByUser,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  String toString() => 'CertificationModel(idCertification: $idCertification, status: $status)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is CertificationModel &&
    runtimeType == other.runtimeType &&
    idCertification == other.idCertification;

  @override
  int get hashCode => idCertification.hashCode;
}