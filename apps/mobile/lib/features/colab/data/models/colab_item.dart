import 'package:csquare_connect/features/colab/data/models/colab_type.dart';

class ColabItem {
  final String id;
  final String? imageUrl;
  final String title;
  final String description;
  final ColabType type;
  final String requirements;
  final int? maxMembers;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int joinedCount;

  ColabItem({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.type,
    required this.requirements,
    this.maxMembers,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.joinedCount,
  });

  factory ColabItem.fromJson(Map<String, dynamic> json) {
    return ColabItem(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ColabTypeExtension.fromString(json['type'] as String),
      requirements: json['requirements'] as String? ?? '',
      maxMembers: json['maxMembers'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      joinedCount: json['joinedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'type': type.value,
      'requirements': requirements,
      'maxMembers': maxMembers,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'joinedCount': joinedCount,
    };
  }
}
