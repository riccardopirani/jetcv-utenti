import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification user model representing the certification_user table
class CertificationUserModel {
  final String idCertificationUser;
  final String idCertification;
  final String idUser;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationUserStatus status;
  final String serialNumber;
  final String? rejectionReason;
  final String idOtp;

  CertificationUserModel({
    required this.idCertificationUser,
    required this.idCertification,
    required this.idUser,
    required this.createdAt,
    this.updatedAt,
    this.status = CertificationUserStatus.draft,
    required this.serialNumber,
    this.rejectionReason,
    required this.idOtp,
  });

  /// Create CertificationUserModel from JSON/Map
  factory CertificationUserModel.fromJson(Map<String, dynamic> json) =>
      CertificationUserModel(
        idCertificationUser: json['id_certification_user'] as String,
        idCertification: json['id_certification'] as String,
        idUser: json['id_user'] as String,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        status: json['status'] != null
            ? CertificationUserStatus.fromString(json['status'])
            : CertificationUserStatus.draft,
        serialNumber: json['serial_number'] as String,
        rejectionReason: json['rejection_reason'] as String?,
        idOtp: json['id_otp'] as String,
      );

  /// Convert CertificationUserModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_user': idCertificationUser,
        'id_certification': idCertification,
        'id_user': idUser,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'status': status.toDbString(),
        'serial_number': serialNumber,
        'rejection_reason': rejectionReason,
        'id_otp': idOtp,
      };

  /// Create copy with updated fields
  CertificationUserModel copyWith({
    DateTime? updatedAt,
    CertificationUserStatus? status,
    String? rejectionReason,
  }) =>
      CertificationUserModel(
        idCertificationUser: idCertificationUser,
        idCertification: idCertification,
        idUser: idUser,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        status: status ?? this.status,
        serialNumber: serialNumber,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        idOtp: idOtp,
      );

  @override
  String toString() =>
      'CertificationUserModel(idCertificationUser: $idCertificationUser, serialNumber: $serialNumber, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationUserModel &&
          runtimeType == other.runtimeType &&
          idCertificationUser == other.idCertificationUser;

  @override
  int get hashCode => idCertificationUser.hashCode;
}

