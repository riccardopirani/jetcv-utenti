/// CV model representing the cv table
class CvModel {
  final String idCv;
  final String idUser;
  final String idWallet;
  final String? nftTokenId;
  final String? nftMintTransactionUrl;
  final String? nftMintTransactionHash;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? firstName;
  final String? firstNameHash;
  final String? lastName;
  final String? lastNameHash;
  final String? email;
  final String? emailHash;
  final String? phone;
  final String? phoneHash;
  final String? dateOfBirth;
  final String? dateOfBirthHash;
  final String? address;
  final String? addressHash;
  final String? city;
  final String? cityHash;
  final String? state;
  final String? stateHash;
  final String? postalCode;
  final String? postalCodeHash;
  final String? countryCode;
  final String? countryCodeHash;
  final String? profilePicture;
  final String? profilePictureHash;
  final String? gender;
  final String? genderHash;
  final String? ipfsCid;
  final String? ipfsUrl;
  final String? idCvHash;
  final String? firstNameSalt;
  final String? lastNameSalt;
  final String? emailSalt;
  final String? phoneSalt;
  final String? dateOfBirthSalt;
  final String? addressSalt;
  final String? citySalt;
  final String? stateSalt;
  final String? postalCodeSalt;
  final String? countrySalt;
  final String? profilePictureSalt;
  final String? genderSalt;
  final String serialNumber;
  final String? serialNumberHash;
  final String? serialNumberSalt;
  final String? publicId;
  final List<String>? nationalityCodes;
  final List<String>? nationalityCodesHash;
  final List<String>? nationalityCodesSalt;
  final List<String>? languageCodes;
  final List<String>? languageCodesHash;
  final List<String>? languageCodesSalt;

  CvModel({
    required this.idCv,
    required this.idUser,
    required this.idWallet,
    this.nftTokenId,
    this.nftMintTransactionUrl,
    this.nftMintTransactionHash,
    required this.createdAt,
    this.updatedAt,
    this.firstName,
    this.firstNameHash,
    this.lastName,
    this.lastNameHash,
    this.email,
    this.emailHash,
    this.phone,
    this.phoneHash,
    this.dateOfBirth,
    this.dateOfBirthHash,
    this.address,
    this.addressHash,
    this.city,
    this.cityHash,
    this.state,
    this.stateHash,
    this.postalCode,
    this.postalCodeHash,
    this.countryCode,
    this.countryCodeHash,
    this.profilePicture,
    this.profilePictureHash,
    this.gender,
    this.genderHash,
    this.ipfsCid,
    this.ipfsUrl,
    this.idCvHash,
    this.firstNameSalt,
    this.lastNameSalt,
    this.emailSalt,
    this.phoneSalt,
    this.dateOfBirthSalt,
    this.addressSalt,
    this.citySalt,
    this.stateSalt,
    this.postalCodeSalt,
    this.countrySalt,
    this.profilePictureSalt,
    this.genderSalt,
    required this.serialNumber,
    this.serialNumberHash,
    this.serialNumberSalt,
    this.publicId,
    this.nationalityCodes,
    this.nationalityCodesHash,
    this.nationalityCodesSalt,
    this.languageCodes,
    this.languageCodesHash,
    this.languageCodesSalt,
  });

  /// Create CvModel from JSON/Map
  factory CvModel.fromJson(Map<String, dynamic> json) => CvModel(
        idCv: json['idCv'] as String,
        idUser: json['idUser'] as String,
        idWallet: json['idWallet'] as String,
        nftTokenId: json['nftTokenId'] as String?,
        nftMintTransactionUrl: json['nftMintTransactionUrl'] as String?,
        nftMintTransactionHash: json['nftMintTransactionHash'] as String?,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        firstName: json['firstName'] as String?,
        firstNameHash: json['firstNameHash'] as String?,
        lastName: json['lastName'] as String?,
        lastNameHash: json['lastNameHash'] as String?,
        email: json['email'] as String?,
        emailHash: json['emailHash'] as String?,
        phone: json['phone'] as String?,
        phoneHash: json['phoneHash'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        dateOfBirthHash: json['dateOfBirthHash'] as String?,
        address: json['address'] as String?,
        addressHash: json['addressHash'] as String?,
        city: json['city'] as String?,
        cityHash: json['cityHash'] as String?,
        state: json['state'] as String?,
        stateHash: json['stateHash'] as String?,
        postalCode: json['postalCode'] as String?,
        postalCodeHash: json['postalCodeHash'] as String?,
        countryCode: json['countryCode'] as String?,
        countryCodeHash: json['countryCodeHash'] as String?,
        profilePicture: json['profilePicture'] as String?,
        profilePictureHash: json['profilePictureHash'] as String?,
        gender: json['gender'] as String?,
        genderHash: json['genderHash'] as String?,
        ipfsCid: json['ipfsCid'] as String?,
        ipfsUrl: json['ipfsUrl'] as String?,
        idCvHash: json['idCvHash'] as String?,
        firstNameSalt: json['firstNameSalt'] as String?,
        lastNameSalt: json['lastNameSalt'] as String?,
        emailSalt: json['emailSalt'] as String?,
        phoneSalt: json['phoneSalt'] as String?,
        dateOfBirthSalt: json['dateOfBirthSalt'] as String?,
        addressSalt: json['addressSalt'] as String?,
        citySalt: json['citySalt'] as String?,
        stateSalt: json['stateSalt'] as String?,
        postalCodeSalt: json['postalCodeSalt'] as String?,
        countrySalt: json['countryCodeSalt'] as String?,
        profilePictureSalt: json['profilePictureSalt'] as String?,
        genderSalt: json['genderSalt'] as String?,
        serialNumber: json['serial_number'] as String,
        serialNumberHash: json['serial_number_hash'] as String?,
        serialNumberSalt: json['serial_number_salt'] as String?,
        publicId: json['publicId'] as String?,
        nationalityCodes: json['nationality_codes'] != null
            ? List<String>.from(json['nationality_codes'])
            : null,
        nationalityCodesHash: json['nationality_codes_hash'] != null
            ? List<String>.from(json['nationality_codes_hash'])
            : null,
        nationalityCodesSalt: json['nationality_codes_salt'] != null
            ? List<String>.from(json['nationality_codes_salt'])
            : null,
        languageCodes: json['language_codes'] != null
            ? List<String>.from(json['language_codes'])
            : null,
        languageCodesHash: json['language_codes_hash'] != null
            ? List<String>.from(json['language_codes_hash'])
            : null,
        languageCodesSalt: json['language_codes_salt'] != null
            ? List<String>.from(json['language_codes_salt'])
            : null,
      );

  /// Convert CvModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'idCv': idCv,
        'idUser': idUser,
        'idWallet': idWallet,
        'nftTokenId': nftTokenId,
        'nftMintTransactionUrl': nftMintTransactionUrl,
        'nftMintTransactionHash': nftMintTransactionHash,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'firstName': firstName,
        'firstNameHash': firstNameHash,
        'lastName': lastName,
        'lastNameHash': lastNameHash,
        'email': email,
        'emailHash': emailHash,
        'phone': phone,
        'phoneHash': phoneHash,
        'dateOfBirth': dateOfBirth,
        'dateOfBirthHash': dateOfBirthHash,
        'address': address,
        'addressHash': addressHash,
        'city': city,
        'cityHash': cityHash,
        'state': state,
        'stateHash': stateHash,
        'postalCode': postalCode,
        'postalCodeHash': postalCodeHash,
        'countryCode': countryCode,
        'countryCodeHash': countryCodeHash,
        'profilePicture': profilePicture,
        'profilePictureHash': profilePictureHash,
        'gender': gender,
        'genderHash': genderHash,
        'ipfsCid': ipfsCid,
        'ipfsUrl': ipfsUrl,
        'idCvHash': idCvHash,
        'firstNameSalt': firstNameSalt,
        'lastNameSalt': lastNameSalt,
        'emailSalt': emailSalt,
        'phoneSalt': phoneSalt,
        'dateOfBirthSalt': dateOfBirthSalt,
        'addressSalt': addressSalt,
        'citySalt': citySalt,
        'stateSalt': stateSalt,
        'postalCodeSalt': postalCodeSalt,
        'countryCodeSalt': countrySalt,
        'profilePictureSalt': profilePictureSalt,
        'genderSalt': genderSalt,
        'serial_number': serialNumber,
        'serial_number_hash': serialNumberHash,
        'serial_number_salt': serialNumberSalt,
        'publicId': publicId,
        'nationality_codes': nationalityCodes,
        'nationality_codes_hash': nationalityCodesHash,
        'nationality_codes_salt': nationalityCodesSalt,
        'language_codes': languageCodes,
        'language_codes_hash': languageCodesHash,
        'language_codes_salt': languageCodesSalt,
      };

  @override
  String toString() => 'CvModel(idCv: $idCv, serialNumber: $serialNumber)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CvModel &&
          runtimeType == other.runtimeType &&
          idCv == other.idCv;

  @override
  int get hashCode => idCv.hashCode;
}
