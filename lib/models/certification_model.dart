import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification model representing the certification table
class CertificationModel {
  final String idCertification;
  final String idCertificationHash;
  final String idCertifier;
  final String idLegalEntity;
  final CertificationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String serialNumber;
  final String idLocation;
  final int nUsers;
  final DateTime? sentAt;
  final DateTime? draftAt;
  final DateTime? closedAt;
  final String idCertificationCategory;

  CertificationModel({
    required this.idCertification,
    required this.idCertificationHash,
    required this.idCertifier,
    required this.idLegalEntity,
    this.status = CertificationStatus.draft,
    required this.createdAt,
    this.updatedAt,
    required this.serialNumber,
    required this.idLocation,
    required this.nUsers,
    this.sentAt,
    this.draftAt,
    this.closedAt,
    required this.idCertificationCategory,
  });

  /// Create CertificationModel from JSON/Map
  factory CertificationModel.fromJson(Map<String, dynamic> json) =>
      CertificationModel(
        idCertification: json['id_certification'] as String,
        idCertificationHash: json['id_certification_hash'] as String,
        idCertifier: json['id_certifier'] as String,
        idLegalEntity: json['id_legal_entity'] as String,
        status: json['status'] != null
            ? CertificationStatus.fromString(json['status'])
            : CertificationStatus.draft,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_t'] != null
            ? DateTime.parse(json['updated_t'])
            : null,
        serialNumber: json['serial_number'] as String,
        idLocation: json['id_location'] as String,
        nUsers: json['n_users'] as int,
        sentAt:
            json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
        draftAt:
            json['draft_at'] != null ? DateTime.parse(json['draft_at']) : null,
        closedAt: json['closed_at'] != null
            ? DateTime.parse(json['closed_at'])
            : null,
        idCertificationCategory: json['id_certification_category'] as String,
      );

  /// Convert CertificationModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification': idCertification,
        'id_certification_hash': idCertificationHash,
        'id_certifier': idCertifier,
        'id_legal_entity': idLegalEntity,
        'status': status.toDbString(),
        'created_at': createdAt.toIso8601String(),
        'updated_t': updatedAt?.toIso8601String(),
        'serial_number': serialNumber,
        'id_location': idLocation,
        'n_users': nUsers,
        'sent_at': sentAt?.toIso8601String(),
        'draft_at': draftAt?.toIso8601String(),
        'closed_at': closedAt?.toIso8601String(),
        'id_certification_category': idCertificationCategory,
      };

  /// Create copy with updated fields
  CertificationModel copyWith({
    CertificationStatus? status,
    DateTime? updatedAt,
    DateTime? sentAt,
    DateTime? draftAt,
    DateTime? closedAt,
  }) =>
      CertificationModel(
        idCertification: idCertification,
        idCertificationHash: idCertificationHash,
        idCertifier: idCertifier,
        idLegalEntity: idLegalEntity,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        serialNumber: serialNumber,
        idLocation: idLocation,
        nUsers: nUsers,
        sentAt: sentAt ?? this.sentAt,
        draftAt: draftAt ?? this.draftAt,
        closedAt: closedAt ?? this.closedAt,
        idCertificationCategory: idCertificationCategory,
      );

  @override
  String toString() =>
      'CertificationModel(idCertification: $idCertification, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationModel &&
          runtimeType == other.runtimeType &&
          idCertification == other.idCertification;

  @override
  int get hashCode => idCertification.hashCode;
}
