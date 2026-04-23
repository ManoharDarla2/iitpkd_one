/// Metadata for the mess menu, used for cache invalidation.
///
/// The app compares the local [updatedAt] with the server's value
/// to decide whether to re-fetch the full 14-day menu.
class MessMetadata {
  final DateTime updatedAt;
  final String version;

  const MessMetadata({required this.updatedAt, required this.version});

  factory MessMetadata.fromJson(Map<String, dynamic> json) {
    return MessMetadata(
      updatedAt: DateTime.parse(
        (json['updated_at'] ?? json['updatedAt']) as String,
      ),
      version: (json['version'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'updated_at': updatedAt.toIso8601String(), 'version': version};
  }
}
