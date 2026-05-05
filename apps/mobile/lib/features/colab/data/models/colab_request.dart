import 'package:csquare_connect/features/colab/data/models/request_type.dart';
import 'package:csquare_connect/features/colab/data/models/request_status.dart';

class ColabRequest {
  final String id;
  final String colabId;
  final String requesterId;
  final String recipientId;
  final RequestType type;
  final RequestStatus status;
  final String message;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ColabRequest({
    required this.id,
    required this.colabId,
    required this.requesterId,
    required this.recipientId,
    required this.type,
    required this.status,
    required this.message,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColabRequest.fromJson(Map<String, dynamic> json) {
    return ColabRequest(
      id: json['id'] as String,
      colabId: json['colabId'] as String,
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String,
      type: RequestTypeExtension.fromString(json['type'] as String),
      status: RequestStatusExtension.fromString(json['status'] as String),
      message: json['message'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colabId': colabId,
      'requesterId': requesterId,
      'recipientId': recipientId,
      'type': type.value,
      'status': status.value,
      'message': message,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
