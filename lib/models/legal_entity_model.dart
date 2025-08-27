import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Legal entity model representing the legal_entity table
class LegalEntityModel {
  final String idLegalEntity;
  final String idLegalEntityHash;
  final String legalName;
  final String identifierCode;
  final String operationalAddress;
  final String headquartersAddress;
  final String legalRepresentative;
  final String email;
  final String phone;
  final String? pec;
  final String? website;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? statusUpdatedAt;
  final String? statusUpdatedByIdUser;
  final String requestingIdUser;
  final LegalEntityStatus status;
  final String? logoPictureUrl;
  final String? companyPictureUrl;
  final String? address;
  final String? city;
  final String? state;
  final String? postalcode;
  final String? countrycode;

  LegalEntityModel({
    required this.idLegalEntity,
    required this.idLegalEntityHash,
    required this.legalName,
    required this.identifierCode,
    required this.operationalAddress,
    required this.headquartersAddress,
    required this.legalRepresentative,
    required this.email,
    required this.phone,
    this.pec,
    this.website,
    required this.createdAt,
    this.updatedAt,
    this.statusUpdatedAt,
    this.statusUpdatedByIdUser,
    required this.requestingIdUser,
    this.status = LegalEntityStatus.pending,
    this.logoPictureUrl,
    this.companyPictureUrl,
    this.address,
    this.city,
    this.state,
    this.postalcode,
    this.countrycode,
  });

  /// Create LegalEntityModel from JSON/Map
  factory LegalEntityModel.fromJson(Map<String, dynamic> json) => LegalEntityModel(
    idLegalEntity: json['idLegalEntity'] as String,
    idLegalEntityHash: json['idLegalEntityHash'] as String,
    legalName: json['legalName'] as String,
    identifierCode: json['identifierCode'] as String,
    operationalAddress: json['operationalAddress'] as String,
    headquartersAddress: json['headquartersAddress'] as String,
    legalRepresentative: json['legalRepresentative'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    pec: json['pec'] as String?,
    website: json['website'] as String?,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    statusUpdatedAt: json['statusUpdatedAt'] != null ? DateTime.parse(json['statusUpdatedAt']) : null,
    statusUpdatedByIdUser: json['statusUpdatedByIdUser'] as String?,
    requestingIdUser: json['requestingIdUser'] as String,
    status: json['status'] != null ? LegalEntityStatus.fromString(json['status']) : LegalEntityStatus.pending,
    logoPictureUrl: json['logoPictureUrl'] as String?,
    companyPictureUrl: json['companyPictureUrl'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    postalcode: json['postalcode'] as String?,
    countrycode: json['countrycode'] as String?,
  );

  /// Convert LegalEntityModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'idLegalEntity': idLegalEntity,
    'idLegalEntityHash': idLegalEntityHash,
    'legalName': legalName,
    'identifierCode': identifierCode,
    'operationalAddress': operationalAddress,
    'headquartersAddress': headquartersAddress,
    'legalRepresentative': legalRepresentative,
    'email': email,
    'phone': phone,
    'pec': pec,
    'website': website,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
    'statusUpdatedByIdUser': statusUpdatedByIdUser,
    'requestingIdUser': requestingIdUser,
    'status': status.toDbString(),
    'logoPictureUrl': logoPictureUrl,
    'companyPictureUrl': companyPictureUrl,
    'address': address,
    'city': city,
    'state': state,
    'postalcode': postalcode,
    'countrycode': countrycode,
  };

  /// Create copy with updated fields
  LegalEntityModel copyWith({
    String? legalName,
    String? identifierCode,
    String? operationalAddress,
    String? headquartersAddress,
    String? legalRepresentative,
    String? email,
    String? phone,
    String? pec,
    String? website,
    DateTime? updatedAt,
    DateTime? statusUpdatedAt,
    String? statusUpdatedByIdUser,
    LegalEntityStatus? status,
    String? logoPictureUrl,
    String? companyPictureUrl,
    String? address,
    String? city,
    String? state,
    String? postalcode,
    String? countrycode,
  }) => LegalEntityModel(
    idLegalEntity: idLegalEntity,
    idLegalEntityHash: idLegalEntityHash,
    legalName: legalName ?? this.legalName,
    identifierCode: identifierCode ?? this.identifierCode,
    operationalAddress: operationalAddress ?? this.operationalAddress,
    headquartersAddress: headquartersAddress ?? this.headquartersAddress,
    legalRepresentative: legalRepresentative ?? this.legalRepresentative,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    pec: pec ?? this.pec,
    website: website ?? this.website,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    statusUpdatedAt: statusUpdatedAt,
    statusUpdatedByIdUser: statusUpdatedByIdUser ?? this.statusUpdatedByIdUser,
    requestingIdUser: requestingIdUser,
    status: status ?? this.status,
    logoPictureUrl: logoPictureUrl ?? this.logoPictureUrl,
    companyPictureUrl: companyPictureUrl ?? this.companyPictureUrl,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    postalcode: postalcode ?? this.postalcode,
    countrycode: countrycode ?? this.countrycode,
  );

  @override
  String toString() => 'LegalEntityModel(idLegalEntity: $idLegalEntity, legalName: $legalName, status: $status)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LegalEntityModel &&
    runtimeType == other.runtimeType &&
    idLegalEntity == other.idLegalEntity;

  @override
  int get hashCode => idLegalEntity.hashCode;
}