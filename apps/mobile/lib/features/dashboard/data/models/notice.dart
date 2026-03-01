import 'package:iitpkd_one/features/dashboard/data/models/notice_location.dart';

/// Represents a campus notice/update.
///
/// Notices are dynamic and change frequently.
/// They should NOT be cached with Hive.
class Notice {
  final String id;
  final String title;
  final String category;
  final String importance;
  final NoticeLocation location;
  final String timeDisplay;
  final String description;

  const Notice({
    required this.id,
    required this.title,
    required this.category,
    required this.importance,
    required this.location,
    required this.timeDisplay,
    required this.description,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      importance: json['importance'] as String,
      location: NoticeLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      timeDisplay: json['time_display'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'importance': importance,
      'location': location.toJson(),
      'time_display': timeDisplay,
      'description': description,
    };
  }

  /// Whether this notice is marked as critical importance.
  bool get isCritical => importance == 'critical';
}
