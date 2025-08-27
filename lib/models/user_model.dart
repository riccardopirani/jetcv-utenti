import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// User model representing the user table
class UserModel {
  final String idUser;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final String? languageCode;
  final String? profilePicture;
  final UserGender? gender;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fullName;
  final UserType? type;
  final bool hasWallet;
  final String? idWallet;
  final bool hasCv;
  final String? idCv;
  final String idUserHash;
  final bool profileCompleted;
  final bool? kycCompleted;
  final bool? kycPassed;

  UserModel({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    this.languageCode,
    this.profilePicture,
    this.gender,
    required this.createdAt,
    this.updatedAt,
    this.fullName,
    this.type,
    this.hasWallet = false,
    this.idWallet,
    this.hasCv = false,
    this.idCv,
    required this.idUserHash,
    this.profileCompleted = false,
    this.kycCompleted,
    this.kycPassed,
  });

  /// Create UserModel from JSON/Map
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    idUser: json['idUser'] as String,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    postalCode: json['postalCode'] as String?,
    countryCode: json['countryCode'] as String?,
    languageCode: json['languageCode'] as String?,
    profilePicture: json['profilePicture'] as String?,
    gender: json['gender'] != null ? UserGender.fromString(json['gender']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    fullName: json['fullName'] as String?,
    type: json['type'] != null ? UserType.fromString(json['type']) : null,
    hasWallet: json['hasWallet'] as bool? ?? false,
    idWallet: json['idWallet'] as String?,
    hasCv: json['hasCv'] as bool? ?? false,
    idCv: json['idCv'] as String?,
    idUserHash: json['idUserHash'] as String,
    profileCompleted: json['profileCompleted'] as bool? ?? false,
    kycCompleted: json['kycCompleted'] as bool?,
    kycPassed: json['kycPassed'] as bool?,
  );

  /// Convert UserModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'idUser': idUser,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0], // Date only
    'address': address,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'countryCode': countryCode,
    'languageCode': languageCode,
    'profilePicture': profilePicture,
    'gender': gender?.toDbString(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'fullName': fullName,
    'type': type?.toDbString(),
    'hasWallet': hasWallet,
    'idWallet': idWallet,
    'hasCv': hasCv,
    'idCv': idCv,
    'idUserHash': idUserHash,
    'profileCompleted': profileCompleted,
    'kycCompleted': kycCompleted,
    'kycPassed': kycPassed,
  };

  /// Create copy with updated fields
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    String? languageCode,
    String? profilePicture,
    UserGender? gender,
    DateTime? updatedAt,
    String? fullName,
    UserType? type,
    bool? hasWallet,
    String? idWallet,
    bool? hasCv,
    String? idCv,
    bool? profileCompleted,
    bool? kycCompleted,
    bool? kycPassed,
  }) => UserModel(
    idUser: idUser,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    postalCode: postalCode ?? this.postalCode,
    countryCode: countryCode ?? this.countryCode,
    languageCode: languageCode ?? this.languageCode,
    profilePicture: profilePicture ?? this.profilePicture,
    gender: gender ?? this.gender,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    fullName: fullName ?? this.fullName,
    type: type ?? this.type,
    hasWallet: hasWallet ?? this.hasWallet,
    idWallet: idWallet ?? this.idWallet,
    hasCv: hasCv ?? this.hasCv,
    idCv: idCv ?? this.idCv,
    idUserHash: idUserHash,
    profileCompleted: profileCompleted ?? this.profileCompleted,
    kycCompleted: kycCompleted ?? this.kycCompleted,
    kycPassed: kycPassed ?? this.kycPassed,
  );

  @override
  String toString() => 'UserModel(idUser: $idUser, email: $email, fullName: $fullName)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is UserModel &&
    runtimeType == other.runtimeType &&
    idUser == other.idUser;

  @override
  int get hashCode => idUser.hashCode;
}