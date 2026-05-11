/// Metadata for the mess menu, used for cache invalidation.
///
/// The app compares the local [updatedAt] with the server's value
/// to decide whether to re-fetch the full 14-day menu.
/// [calculatedWeek] is the server-determined current week type ("odd"/"even").
class MessMetadata {
  final DateTime updatedAt;
  final String version;
  final String? calculatedWeek;

  const MessMetadata({required this.updatedAt, required this.version, this.calculatedWeek});

  factory MessMetadata.fromJson(Map<String, dynamic> json) {
    return MessMetadata(
      updatedAt: DateTime.parse(
        (json['updated_at'] ?? json['updatedAt']) as String,
      ),
      version: (json['version'] ?? '') as String,
      calculatedWeek: (json['calculated_week'] ?? json['calculatedWeek']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updated_at': updatedAt.toIso8601String(),
      'version': version,
      'calculated_week': calculatedWeek,
    };
  }
}
