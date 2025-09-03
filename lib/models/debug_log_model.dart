/// Debug log model representing the debug_log table
class DebugLogModel {
  final String idDebugLog;
  final DateTime? ts;
  final String? message;

  DebugLogModel({
    required this.idDebugLog,
    this.ts,
    this.message,
  });

  /// Create DebugLogModel from JSON/Map
  factory DebugLogModel.fromJson(Map<String, dynamic> json) => DebugLogModel(
        idDebugLog: json['id_debug_log'] as String,
        ts: json['ts'] != null ? DateTime.parse(json['ts']) : null,
        message: json['message'] as String?,
      );

  /// Convert DebugLogModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_debug_log': idDebugLog,
        'ts': ts?.toIso8601String(),
        'message': message,
      };

  @override
  String toString() =>
      'DebugLogModel(idDebugLog: $idDebugLog, ts: $ts, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebugLogModel &&
          runtimeType == other.runtimeType &&
          idDebugLog == other.idDebugLog;

  @override
  int get hashCode => idDebugLog.hashCode;
}
