/// Country model representing the country table
class CountryModel {
  final String code;
  final String name;
  final DateTime createdAt;
  final String? emoji;

  CountryModel({
    required this.code,
    required this.name,
    required this.createdAt,
    this.emoji,
  });

  /// Create CountryModel from JSON/Map
  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        code: json['code'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt']),
        emoji: json['emoji'] as String?,
      );

  /// Convert CountryModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'emoji': emoji,
      };

  @override
  String toString() => 'CountryModel(code: $code, name: $name, emoji: $emoji)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
