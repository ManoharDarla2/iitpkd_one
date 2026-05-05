import 'dart:convert';

import 'package:csquare_connect/core/network/api_client_interface.dart';
import 'package:csquare_connect/core/services/hive_service.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_request.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';

class ColabRepository {
  final ApiClientInterface _apiClient;
  final HiveService _hiveService;

  ColabRepository({
    required ApiClientInterface apiClient,
    required HiveService hiveService,
  })  : _apiClient = apiClient,
        _hiveService = hiveService;

  Future<List<ColabItem>> getColabs({
    ColabType? type,
    bool? isActive,
    String? createdBy,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _hiveService.isColabCacheValid()) {
      final cached = _hiveService.getCachedColabList();
      if (cached != null) {
        return _filterColabs(cached, type: type, isActive: isActive, createdBy: createdBy);
      }
    }

    final response = await _apiClient.getColabs(
      type: type,
      isActive: isActive,
      createdBy: createdBy,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch colabs');
    }

    await _hiveService.cacheColabList(jsonEncode(response.data!));
    return response.data!;
  }

  List<ColabItem> _filterColabs(
    List<ColabItem> colabs, {
    ColabType? type,
    bool? isActive,
    String? createdBy,
  }) {
    return colabs.where((colab) {
      if (type != null && colab.type != type) return false;
      if (isActive != null && colab.isActive != isActive) return false;
      if (createdBy != null && colab.createdBy != createdBy) return false;
      return true;
    }).toList();
  }

  Future<ColabItem> getColabDetail({required String id}) async {
    final response = await _apiClient.getColabDetail(id: id);
    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch colab detail');
    }
    return response.data!;
  }

  Future<ColabItem> createColab({
    required String title,
    required String description,
    required ColabType type,
    String? requirements,
    int? maxMembers,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final response = await _apiClient.createColab(
      title: title,
      description: description,
      type: type,
      requirements: requirements,
      maxMembers: maxMembers,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to create colab');
    }

    await _hiveService.clearColabCache();
    return response.data!;
  }

  Future<ColabItem> updateColab({
    required String id,
    String? title,
    String? description,
    ColabType? type,
    String? requirements,
    int? maxMembers,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final response = await _apiClient.updateColab(
      id: id,
      title: title,
      description: description,
      type: type,
      requirements: requirements,
      maxMembers: maxMembers,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to update colab');
    }

    await _hiveService.clearColabCache();
    return response.data!;
  }

  Future<void> deleteColab({required String id}) async {
    final response = await _apiClient.deleteColab(id: id);
    if (response.isError) {
      throw Exception(response.error ?? 'Failed to delete colab');
    }
    await _hiveService.clearColabCache();
  }

  Future<ColabRequest> createJoinRequest({
    required String colabId,
    String? message,
    DateTime? expiresAt,
  }) async {
    final response = await _apiClient.createJoinRequest(
      colabId: colabId,
      message: message,
      expiresAt: expiresAt,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to create join request');
    }
    return response.data!;
  }

  Future<ColabRequest> createInviteRequest({
    required String colabId,
    required String recipientId,
    String? message,
    DateTime? expiresAt,
  }) async {
    final response = await _apiClient.createInviteRequest(
      colabId: colabId,
      recipientId: recipientId,
      message: message,
      expiresAt: expiresAt,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to create invite request');
    }
    return response.data!;
  }

  Future<List<ColabRequest>> getIncomingRequests() async {
    final response = await _apiClient.getIncomingRequests();
    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch requests');
    }
    return response.data!;
  }

  Future<ColabRequest> acceptRequest({required String requestId}) async {
    final response = await _apiClient.acceptRequest(requestId: requestId);
    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to accept request');
    }
    await _hiveService.clearColabCache();
    return response.data!;
  }

  Future<ColabRequest> rejectRequest({required String requestId}) async {
    final response = await _apiClient.rejectRequest(requestId: requestId);
    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to reject request');
    }
    return response.data!;
  }
}
