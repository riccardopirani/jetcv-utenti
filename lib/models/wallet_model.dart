import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Wallet model representing the wallet table
class WalletModel {
  final String idWallet;
  final String idUser;
  final String secretKey;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final WalletCreatedBy createdBy;
  final String publicAddress;

  WalletModel({
    required this.idWallet,
    required this.idUser,
    required this.secretKey,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.publicAddress,
  });

  /// Create WalletModel from JSON/Map
  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        idWallet: json['idWallet'] as String,
        idUser: json['idUser'] as String,
        secretKey: json['secretKey'] as String,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        createdBy: WalletCreatedBy.fromString(json['createdBy']),
        publicAddress: json['publicAddress'] as String,
      );

  /// Convert WalletModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'idWallet': idWallet,
        'idUser': idUser,
        'secretKey': secretKey,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'createdBy': createdBy.toDbString(),
        'publicAddress': publicAddress,
      };

  /// Create copy with updated fields
  WalletModel copyWith({
    DateTime? updatedAt,
    String? publicAddress,
  }) =>
      WalletModel(
        idWallet: idWallet,
        idUser: idUser,
        secretKey: secretKey,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        createdBy: createdBy,
        publicAddress: publicAddress ?? this.publicAddress,
      );

  @override
  String toString() =>
      'WalletModel(idWallet: $idWallet, publicAddress: $publicAddress)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletModel &&
          runtimeType == other.runtimeType &&
          idWallet == other.idWallet;

  @override
  int get hashCode => idWallet.hashCode;
}
