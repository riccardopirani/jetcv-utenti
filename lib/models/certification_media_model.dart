import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification media model representing the certification_media table
class CertificationMediaModel {
  final String idCertificationMedia;
  final String idMediaHash;
  final String idCertification;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? description;
  final CertificationMediaAcquisitionType acquisitionType;
  final DateTime capturedAt;
  final String? idLocation;
  final CertificationMediaFileType fileType;

  CertificationMediaModel({
    required this.idCertificationMedia,
    required this.idMediaHash,
    required this.idCertification,
    required this.createdAt,
    this.updatedAt,
    this.name,
    this.description,
    required this.acquisitionType,
    required this.capturedAt,
    this.idLocation,
    required this.fileType,
  });

  /// Create CertificationMediaModel from JSON/Map
  factory CertificationMediaModel.fromJson(Map<String, dynamic> json) =>
      CertificationMediaModel(
        idCertificationMedia: json['id_certification_media'] as String,
        idMediaHash: json['id_media_hash'] as String,
        idCertification: json['id_certification'] as String,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        name: json['name'] as String?,
        description: json['description'] as String?,
        acquisitionType: CertificationMediaAcquisitionType.fromString(
            json['acquisition_type']),
        capturedAt: DateTime.parse(json['captured_at']),
        idLocation: json['id_location'] as String?,
        fileType: CertificationMediaFileType.fromString(json['file_type']),
      );

  /// Convert CertificationMediaModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_media': idCertificationMedia,
        'id_media_hash': idMediaHash,
        'id_certification': idCertification,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'name': name,
        'description': description,
        'acquisition_type': acquisitionType.toDbString(),
        'captured_at': capturedAt.toIso8601String(),
        'id_location': idLocation,
        'file_type': fileType.toDbString(),
      };

  /// Create copy with updated fields
  CertificationMediaModel copyWith({
    DateTime? updatedAt,
    String? name,
    String? description,
    CertificationMediaAcquisitionType? acquisitionType,
    DateTime? capturedAt,
    String? idLocation,
    CertificationMediaFileType? fileType,
  }) =>
      CertificationMediaModel(
        idCertificationMedia: idCertificationMedia,
        idMediaHash: idMediaHash,
        idCertification: idCertification,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        name: name ?? this.name,
        description: description ?? this.description,
        acquisitionType: acquisitionType ?? this.acquisitionType,
        capturedAt: capturedAt ?? this.capturedAt,
        idLocation: idLocation ?? this.idLocation,
        fileType: fileType ?? this.fileType,
      );

  @override
  String toString() =>
      'CertificationMediaModel(idCertificationMedia: $idCertificationMedia, name: $name, fileType: $fileType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationMediaModel &&
          runtimeType == other.runtimeType &&
          idCertificationMedia == other.idCertificationMedia;

  @override
  int get hashCode => idCertificationMedia.hashCode;
}


