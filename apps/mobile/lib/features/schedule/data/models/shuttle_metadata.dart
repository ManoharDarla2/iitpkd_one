/// Metadata for shuttle schedules, used for cache invalidation.
///
/// The app can compare the local [updatedAt] with the server's value
/// to decide whether to re-fetch shuttle data.
class ShuttleMetadata {
  final DateTime updatedAt;
  final String version;

  const ShuttleMetadata({required this.updatedAt, required this.version});

  factory ShuttleMetadata.fromJson(Map<String, dynamic> json) {
    return ShuttleMetadata(
      updatedAt: DateTime.parse(json['updated_at'] as String),
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updated_at': updatedAt.toIso8601String(),
      'version': version,
    };
  }
}
