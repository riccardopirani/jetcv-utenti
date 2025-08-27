/// Debug log model representing the debug_log table
class DebugLogModel {
  final DateTime? ts;
  final String? message;

  DebugLogModel({
    this.ts,
    this.message,
  });

  /// Create DebugLogModel from JSON/Map
  factory DebugLogModel.fromJson(Map<String, dynamic> json) => DebugLogModel(
    ts: json['ts'] != null ? DateTime.parse(json['ts']) : null,
    message: json['message'] as String?,
  );

  /// Convert DebugLogModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'ts': ts?.toIso8601String(),
    'message': message,
  };

  @override
  String toString() => 'DebugLogModel(ts: $ts, message: $message)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DebugLogModel &&
    runtimeType == other.runtimeType &&
    ts == other.ts &&
    message == other.message;

  @override
  int get hashCode => Object.hash(ts, message);
}