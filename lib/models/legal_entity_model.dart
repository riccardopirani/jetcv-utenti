import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Legal entity model representing the legal_entity table
class LegalEntityModel {
  final String idLegalEntity;
  final String idLegalEntityHash;
  final String? legalName;
  final String? identifierCode;
  final String? operationalAddress;
  final String? operationalCity;
  final String? operationalPostalCode;
  final String? operationalState;
  final String? operationalCountry;
  final String? headquarterAddress;
  final String? headquarterCity;
  final String? headquarterPostalCode;
  final String? headquarterState;
  final String? headquarterCountry;
  final String? legalRapresentative;
  final String? email;
  final String? phone;
  final String? pec;
  final String? website;
  final LegalEntityStatus status;
  final String? logoPicture;
  final String? companyPicture;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdByIdUser;

  LegalEntityModel({
    required this.idLegalEntity,
    required this.idLegalEntityHash,
    this.legalName,
    this.identifierCode,
    this.operationalAddress,
    this.operationalCity,
    this.operationalPostalCode,
    this.operationalState,
    this.operationalCountry,
    this.headquarterAddress,
    this.headquarterCity,
    this.headquarterPostalCode,
    this.headquarterState,
    this.headquarterCountry,
    this.legalRapresentative,
    this.email,
    this.phone,
    this.pec,
    this.website,
    this.status = LegalEntityStatus.pending,
    this.logoPicture,
    this.companyPicture,
    required this.createdAt,
    this.updatedAt,
    required this.createdByIdUser,
  });

  /// Create LegalEntityModel from JSON/Map
  factory LegalEntityModel.fromJson(Map<String, dynamic> json) =>
      LegalEntityModel(
        idLegalEntity: json['id_legal_entity'] as String,
        idLegalEntityHash: json['id_legal_entity_hash'] as String,
        legalName: json['legal_name'] as String?,
        identifierCode: json['identifier_code'] as String?,
        operationalAddress: json['operational_address'] as String?,
        operationalCity: json['operational_city'] as String?,
        operationalPostalCode: json['operational_postal_code'] as String?,
        operationalState: json['operational_state'] as String?,
        operationalCountry: json['operational_country'] as String?,
        headquarterAddress: json['headquarter_address'] as String?,
        headquarterCity: json['headquarter_city'] as String?,
        headquarterPostalCode: json['headquarter_postal_code'] as String?,
        headquarterState: json['headquarter_state'] as String?,
        headquarterCountry: json['headquarter_country'] as String?,
        legalRapresentative: json['legal_rapresentative'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        pec: json['pec'] as String?,
        website: json['website'] as String?,
        status: json['status'] != null
            ? LegalEntityStatus.fromString(json['status'])
            : LegalEntityStatus.pending,
        logoPicture: json['logo_picture'] as String?,
        companyPicture: json['company_picture'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        createdByIdUser: json['created_by_id_user'] as String,
      );

  /// Convert LegalEntityModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_legal_entity': idLegalEntity,
        'id_legal_entity_hash': idLegalEntityHash,
        'legal_name': legalName,
        'identifier_code': identifierCode,
        'operational_address': operationalAddress,
        'operational_city': operationalCity,
        'operational_postal_code': operationalPostalCode,
        'operational_state': operationalState,
        'operational_country': operationalCountry,
        'headquarter_address': headquarterAddress,
        'headquarter_city': headquarterCity,
        'headquarter_postal_code': headquarterPostalCode,
        'headquarter_state': headquarterState,
        'headquarter_country': headquarterCountry,
        'legal_rapresentative': legalRapresentative,
        'email': email,
        'phone': phone,
        'pec': pec,
        'website': website,
        'status': status.toDbString(),
        'logo_picture': logoPicture,
        'company_picture': companyPicture,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'created_by_id_user': createdByIdUser,
      };

  /// Create copy with updated fields
  LegalEntityModel copyWith({
    String? legalName,
    String? identifierCode,
    String? operationalAddress,
    String? operationalCity,
    String? operationalPostalCode,
    String? operationalState,
    String? operationalCountry,
    String? headquarterAddress,
    String? headquarterCity,
    String? headquarterPostalCode,
    String? headquarterState,
    String? headquarterCountry,
    String? legalRapresentative,
    String? email,
    String? phone,
    String? pec,
    String? website,
    LegalEntityStatus? status,
    String? logoPicture,
    String? companyPicture,
    DateTime? updatedAt,
  }) =>
      LegalEntityModel(
        idLegalEntity: idLegalEntity,
        idLegalEntityHash: idLegalEntityHash,
        legalName: legalName ?? this.legalName,
        identifierCode: identifierCode ?? this.identifierCode,
        operationalAddress: operationalAddress ?? this.operationalAddress,
        operationalCity: operationalCity ?? this.operationalCity,
        operationalPostalCode:
            operationalPostalCode ?? this.operationalPostalCode,
        operationalState: operationalState ?? this.operationalState,
        operationalCountry: operationalCountry ?? this.operationalCountry,
        headquarterAddress: headquarterAddress ?? this.headquarterAddress,
        headquarterCity: headquarterCity ?? this.headquarterCity,
        headquarterPostalCode:
            headquarterPostalCode ?? this.headquarterPostalCode,
        headquarterState: headquarterState ?? this.headquarterState,
        headquarterCountry: headquarterCountry ?? this.headquarterCountry,
        legalRapresentative: legalRapresentative ?? this.legalRapresentative,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        pec: pec ?? this.pec,
        website: website ?? this.website,
        status: status ?? this.status,
        logoPicture: logoPicture ?? this.logoPicture,
        companyPicture: companyPicture ?? this.companyPicture,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        createdByIdUser: createdByIdUser,
      );

  @override
  String toString() =>
      'LegalEntityModel(idLegalEntity: $idLegalEntity, legalName: $legalName, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalEntityModel &&
          runtimeType == other.runtimeType &&
          idLegalEntity == other.idLegalEntity;

  @override
  int get hashCode => idLegalEntity.hashCode;
}
