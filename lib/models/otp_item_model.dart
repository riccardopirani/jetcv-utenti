/// Model for OTP items used in the UI
class OtpItem {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;
  final bool isActive;

  OtpItem({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.isActive,
  });

  /// Create OtpItem from OtpModel
  factory OtpItem.fromOtpModel(dynamic otpModel, String name) {
    return OtpItem(
      id: otpModel.idOtp,
      name: name,
      code: otpModel.code,
      createdAt: otpModel.createdAt,
      isActive: otpModel.isValid,
    );
  }

  /// Create OtpItem from JSON/Map
  factory OtpItem.fromJson(Map<String, dynamic> json) => OtpItem(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        createdAt: DateTime.parse(json['created_at']),
        isActive: json['is_active'] as bool,
      );

  /// Convert OtpItem to JSON/Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };

  /// Create copy with updated fields
  OtpItem copyWith({
    String? name,
    String? code,
    DateTime? createdAt,
    bool? isActive,
  }) =>
      OtpItem(
        id: id,
        name: name ?? this.name,
        code: code ?? this.code,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
      );

  @override
  String toString() =>
      'OtpItem(id: $id, name: $name, code: $code, isActive: $isActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
