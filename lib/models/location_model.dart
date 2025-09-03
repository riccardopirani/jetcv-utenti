/// Location model representing the location table
class LocationModel {
  final String idLocation;
  final String idUser;
  final DateTime aquiredAt;
  final double latitude;
  final double longitude;
  final double? accuracyM;
  final bool? isMoked;
  final double? altitude;
  final double? altitudeAccuracyM;
  final String? name;
  final String? street;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? isoCountryCode;
  final String? country;
  final String? thoroughfare;
  final String? subThoroughfare;
  final DateTime createdAt;

  LocationModel({
    required this.idLocation,
    required this.idUser,
    required this.aquiredAt,
    required this.latitude,
    required this.longitude,
    this.accuracyM,
    this.isMoked,
    this.altitude,
    this.altitudeAccuracyM,
    this.name,
    this.street,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.isoCountryCode,
    this.country,
    this.thoroughfare,
    this.subThoroughfare,
    required this.createdAt,
  });

  /// Create LocationModel from JSON/Map
  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        idLocation: json['id_location'] as String,
        idUser: json['id_user'] as String,
        aquiredAt: DateTime.parse(json['aquired_at']),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracyM: json['accuracy_m'] != null
            ? (json['accuracy_m'] as num).toDouble()
            : null,
        isMoked: json['is_moked'] as bool?,
        altitude: json['altitude'] != null
            ? (json['altitude'] as num).toDouble()
            : null,
        altitudeAccuracyM: json['altitude_accuracy_m'] != null
            ? (json['altitude_accuracy_m'] as num).toDouble()
            : null,
        name: json['name'] as String?,
        street: json['street'] as String?,
        locality: json['locality'] as String?,
        subLocality: json['sub_locality'] as String?,
        administrativeArea: json['administrative_area'] as String?,
        subAdministrativeArea: json['sub_administrative_area'] as String?,
        postalCode: json['postal_code'] as String?,
        isoCountryCode: json['iso_country_code'] as String?,
        country: json['country'] as String?,
        thoroughfare: json['thoroughfare'] as String?,
        subThoroughfare: json['sub_thoroughfare'] as String?,
        createdAt: DateTime.parse(json['created_at']),
      );

  /// Convert LocationModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_location': idLocation,
        'id_user': idUser,
        'aquired_at': aquiredAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_m': accuracyM,
        'is_moked': isMoked,
        'altitude': altitude,
        'altitude_accuracy_m': altitudeAccuracyM,
        'name': name,
        'street': street,
        'locality': locality,
        'sub_locality': subLocality,
        'administrative_area': administrativeArea,
        'sub_administrative_area': subAdministrativeArea,
        'postal_code': postalCode,
        'iso_country_code': isoCountryCode,
        'country': country,
        'thoroughfare': thoroughfare,
        'sub_thoroughfare': subThoroughfare,
        'created_at': createdAt.toIso8601String(),
      };

  /// Create copy with updated fields
  LocationModel copyWith({
    String? name,
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? postalCode,
    String? isoCountryCode,
    String? country,
    String? thoroughfare,
    String? subThoroughfare,
  }) =>
      LocationModel(
        idLocation: idLocation,
        idUser: idUser,
        aquiredAt: aquiredAt,
        latitude: latitude,
        longitude: longitude,
        accuracyM: accuracyM,
        isMoked: isMoked,
        altitude: altitude,
        altitudeAccuracyM: altitudeAccuracyM,
        name: name ?? this.name,
        street: street ?? this.street,
        locality: locality ?? this.locality,
        subLocality: subLocality ?? this.subLocality,
        administrativeArea: administrativeArea ?? this.administrativeArea,
        subAdministrativeArea:
            subAdministrativeArea ?? this.subAdministrativeArea,
        postalCode: postalCode ?? this.postalCode,
        isoCountryCode: isoCountryCode ?? this.isoCountryCode,
        country: country ?? this.country,
        thoroughfare: thoroughfare ?? this.thoroughfare,
        subThoroughfare: subThoroughfare ?? this.subThoroughfare,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'LocationModel(idLocation: $idLocation, latitude: $latitude, longitude: $longitude, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          idLocation == other.idLocation;

  @override
  int get hashCode => idLocation.hashCode;
}


