/// Certification has media model representing the certification_has_media table
class CertificationHasMediaModel {
  final int idCertificationHasMedia;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? idCertification;
  final String? idCertificationUser;
  final String idCertificationMedia;

  CertificationHasMediaModel({
    required this.idCertificationHasMedia,
    required this.createdAt,
    this.updatedAt,
    this.idCertification,
    this.idCertificationUser,
    required this.idCertificationMedia,
  });

  /// Create CertificationHasMediaModel from JSON/Map
  factory CertificationHasMediaModel.fromJson(Map<String, dynamic> json) =>
      CertificationHasMediaModel(
        idCertificationHasMedia: json['id_certification_has_media'] as int,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        idCertification: json['id_certification'] as String?,
        idCertificationUser: json['id_certification_user'] as String?,
        idCertificationMedia: json['id_certification_media'] as String,
      );

  /// Convert CertificationHasMediaModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_has_media': idCertificationHasMedia,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'id_certification': idCertification,
        'id_certification_user': idCertificationUser,
        'id_certification_media': idCertificationMedia,
      };

  /// Create copy with updated fields
  CertificationHasMediaModel copyWith({
    DateTime? updatedAt,
    String? idCertification,
    String? idCertificationUser,
  }) =>
      CertificationHasMediaModel(
        idCertificationHasMedia: idCertificationHasMedia,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        idCertification: idCertification ?? this.idCertification,
        idCertificationUser: idCertificationUser ?? this.idCertificationUser,
        idCertificationMedia: idCertificationMedia,
      );

  @override
  String toString() =>
      'CertificationHasMediaModel(idCertificationHasMedia: $idCertificationHasMedia, idCertificationMedia: $idCertificationMedia)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationHasMediaModel &&
          runtimeType == other.runtimeType &&
          idCertificationHasMedia == other.idCertificationHasMedia;

  @override
  int get hashCode => idCertificationHasMedia.hashCode;
}


