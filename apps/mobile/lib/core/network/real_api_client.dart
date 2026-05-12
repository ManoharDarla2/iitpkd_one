import 'dart:convert';

import 'package:csquare_connect/core/constants/api_constants.dart';
import 'package:csquare_connect/core/network/api_client_interface.dart';
import 'package:csquare_connect/core/network/api_response.dart';
import 'package:csquare_connect/features/competitions/data/models/competition.dart';
import 'package:csquare_connect/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:csquare_connect/features/faculty/data/models/faculty_detail.dart';
import 'package:csquare_connect/features/faculty/data/models/faculty_member.dart';
import 'package:csquare_connect/features/schedule/data/models/meal_day.dart';
import 'package:csquare_connect/features/schedule/data/models/mess_menu.dart';
import 'package:csquare_connect/features/schedule/data/models/mess_metadata.dart';
import 'package:csquare_connect/features/schedule/data/models/shuttle_metadata.dart';
import 'package:csquare_connect/features/search/data/models/search_result.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_request.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';
import 'package:http/http.dart' as http;
import 'package:better_auth_flutter/better_auth_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBearerTokenKey = 'bearer_token';
const _kUserJsonKey = 'user_json';
const _kSessionJsonKey = 'session_json';

Future<void> saveBearerToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kBearerTokenKey, token);
}

Future<String?> getBearerToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_kBearerTokenKey);
}

Future<void> clearBearerToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kBearerTokenKey);
}

Future<void> saveUserJson(String json) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kUserJsonKey, json);
}

Future<String?> getUserJson() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_kUserJsonKey);
}

Future<void> saveSessionJson(String json) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kSessionJsonKey, json);
}

Future<String?> getSessionJson() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_kSessionJsonKey);
}

Future<void> clearAuthData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kBearerTokenKey);
  await prefs.remove(_kUserJsonKey);
  await prefs.remove(_kSessionJsonKey);
}

class RealApiClient implements ApiClientInterface {
  RealApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, String>> _authHeaders({bool isJson = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    String? token;

    final session = BetterAuth.instance.client.session;
    if (session != null && session.token.isNotEmpty) {
      token = session.token;
    } else {
      token = await getBearerToken();
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return base.replace(
      path: path,
      queryParameters: queryParameters?.isEmpty == true
          ? null
          : queryParameters,
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    print('[CSquare] GET ${_uri(path, queryParameters)}');
    print('[CSquare] Headers: ${await _authHeaders(isJson: false)}');
    final response = await _httpClient.get(
      _uri(path, queryParameters),
      headers: await _authHeaders(isJson: false),
    );
    print('[CSquare] Response status: ${response.statusCode}');
    print('[CSquare] Response body: ${response.body}');

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(response.body) as Map<String, dynamic>);

    if (response.statusCode >= 400) {
      final message =
          (body['message'] as String?) ??
          'HTTP ${response.statusCode} on $path';
      throw Exception(message);
    }

    return body;
  }

  ApiResponse<T> _parseEnvelope<T>(
    Map<String, dynamic> json,
    T Function(dynamic jsonData) parser,
  ) {
    final success = json['success'] == true;
    final message = json['message'] as String?;

    if (!success) {
      return ApiResponse.error(
        error: (json['error'] as String?) ?? message ?? 'Request failed',
        message: message,
      );
    }

    if (!json.containsKey('data')) {
      return ApiResponse.error(error: 'Malformed response: missing data');
    }

    try {
      return ApiResponse.success(data: parser(json['data']), message: message);
    } catch (e) {
      return ApiResponse.error(error: 'Response parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<ShuttleSchedule>>> getShuttleSchedules({
    String? day,
  }) async {
    try {
      final json = await _getJson(
        ApiConstants.shuttleSchedules,
        queryParameters: day != null ? {'day': day} : null,
      );

      return _parseEnvelope<List<ShuttleSchedule>>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(ShuttleSchedule.fromJson).toList();
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ShuttleMetadata>> getShuttleMetadata() async {
    try {
      final json = await _getJson(ApiConstants.shuttleMetadata);
      return _parseEnvelope<ShuttleMetadata>(
        json,
        (data) => ShuttleMetadata.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<MessMenu>> getMessMenu() async {
    try {
      final json = await _getJson(ApiConstants.messMenu);
      return _parseEnvelope<MessMenu>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        final days = list.map(MealDay.fromJson).toList();
        return MessMenu(campus: 'Nila', days: days);
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<MealDay>> getMessMenuToday() async {
    try {
      final json = await _getJson(ApiConstants.messMenuToday);
      return _parseEnvelope<MealDay>(
        json,
        (data) => MealDay.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<MessMetadata>> getMessMetadata() async {
    try {
      final json = await _getJson(ApiConstants.messMetadata);
      return _parseEnvelope<MessMetadata>(
        json,
        (data) => MessMetadata.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<FacultyMember>>> getFacultyList({
    String? department,
  }) async {
    try {
      final json = await _getJson(
        ApiConstants.facultyList,
        queryParameters: department != null ? {'department': department} : null,
      );

      return _parseEnvelope<List<FacultyMember>>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(FacultyMember.fromJson).toList();
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<FacultyDetail>> getFacultyDetail({
    required String slug,
  }) async {
    try {
      final json = await _getJson('${ApiConstants.facultyDetail}/$slug');
      return _parseEnvelope<FacultyDetail>(
        json,
        (data) => FacultyDetail.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<SearchResult>> search({
    required String query,
    String? category,
    int? limit,
  }) async {
    try {
      final json = await _getJson(
        ApiConstants.search,
        queryParameters: {
          'q': query,
          if (category != null && category.isNotEmpty) 'category': category,
          if (limit != null) 'limit': '$limit',
        },
      );

      return _parseEnvelope<SearchResult>(
        json,
        (data) => SearchResult.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<String>>> getSearchSuggestions({
    required String query,
  }) async {
    try {
      final json = await _getJson(
        ApiConstants.searchSuggestions,
        queryParameters: {'q': query},
      );

      return _parseEnvelope<List<String>>(json, (data) {
        final list = (data as List<dynamic>).cast<String>();
        return list;
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Competition>>> getCompetitions() async {
    try {
      final json = await _getJson(ApiConstants.competitions);

      return _parseEnvelope<List<Competition>>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(Competition.fromJson).toList();
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  // -- Colab endpoints implementation --

  @override
  Future<ApiResponse<List<ColabItem>>> getColabs({
    ColabType? type,
    bool? isActive,
    String? createdBy,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type.value;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (createdBy != null) queryParams['createdBy'] = createdBy;

      final json = await _getJson(
        ApiConstants.colabs,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      return _parseEnvelope<List<ColabItem>>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(ColabItem.fromJson).toList();
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabItem>> getColabDetail({required String id}) async {
    try {
      final json = await _getJson('${ApiConstants.colabDetail}/$id');
      return _parseEnvelope<ColabItem>(
        json,
        (data) => ColabItem.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabItem>> createColab({
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
    try {
      print('[CSquare] Creating colab with title: $title, type: ${type.value}');
      print('[CSquare] Requirements: $requirements, maxMembers: $maxMembers, startDate: $startDate, endDate: $endDate, isActive: $isActive');
      print('[CSquare] Image bytes length: ${imageBytes?.length}, imageName: $imageName');
      final request = http.MultipartRequest(
        'POST',
        _uri(ApiConstants.colabs),
      );
      print('[CSquare] Multipart request created for ${_uri(ApiConstants.colabs)}');

      final authHeaders = await _authHeaders(isJson: false);
      request.headers.addAll(authHeaders);

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['type'] = type.value;
      if (requirements != null) request.fields['requirements'] = requirements;
      if (maxMembers != null) request.fields['maxMembers'] = maxMembers.toString();
      if (startDate != null) request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();
      if (isActive != null) request.fields['isActive'] = isActive.toString();
      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', imageBytes, filename: imageName),
        );
      }

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('[CSquare] Create colab response status: ${response.statusCode}');
      print('[CSquare] Create colab response body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(body['message'] ?? 'Failed to create colab');
      }

      final result = _parseEnvelope<ColabItem>(
        body,
        (data) => ColabItem.fromJson(data as Map<String, dynamic>),
      );

      return result;
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabItem>> updateColab({
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
    try {
      print('[CSquare] Updating colab $id with title: $title, type: ${type?.value}');
      print('[CSquare] Requirements: $requirements, maxMembers: $maxMembers, startDate: $startDate, endDate: $endDate, isActive: $isActive');
      print('[CSquare] Image bytes length: ${imageBytes?.length}, imageName: $imageName');
      final request = http.MultipartRequest(
        'PATCH',
        _uri('${ApiConstants.colabDetail}/$id'),
      );

      final authHeaders = await _authHeaders(isJson: false);
      request.headers.addAll(authHeaders);

      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (type != null) request.fields['type'] = type.value;
      if (requirements != null) request.fields['requirements'] = requirements;
      if (maxMembers != null) request.fields['maxMembers'] = maxMembers.toString();
      if (startDate != null) request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();
      if (isActive != null) request.fields['isActive'] = isActive.toString();
      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', imageBytes, filename: imageName),
        );
      }

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('[CSquare] Update colab response status: ${response.statusCode}');
      print('[CSquare] Update colab response body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(body['message'] ?? 'Failed to update colab');
      }

      return _parseEnvelope<ColabItem>(
        body,
        (data) => ColabItem.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> deleteColab({required String id}) async {
    try {
      final response = await _httpClient.delete(
        _uri('${ApiConstants.colabDetail}/$id'),
        headers: await _authHeaders(isJson: false),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(body['message'] ?? 'Failed to delete colab');
      }

      return _parseEnvelope<Map<String, dynamic>>(body, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabRequest>> createJoinRequest({
    required String colabId,
    String? message,
    DateTime? expiresAt,
  }) async {
    try {
      final body = <String, dynamic>{'colabId': colabId};
      if (message != null) body['message'] = message;
      if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();

      final response = await _httpClient.post(
        _uri(ApiConstants.colabJoinRequest),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(json['message'] ?? 'Failed to create join request');
      }

      return _parseEnvelope<ColabRequest>(
        json,
        (data) => ColabRequest.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabRequest>> createInviteRequest({
    required String colabId,
    required String recipientId,
    String? message,
    DateTime? expiresAt,
  }) async {
    try {
      final body = <String, dynamic>{
        'colabId': colabId,
        'recipientId': recipientId,
      };
      if (message != null) body['message'] = message;
      if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();

      final response = await _httpClient.post(
        _uri(ApiConstants.colabInviteRequest),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(json['message'] ?? 'Failed to create invite request');
      }

      return _parseEnvelope<ColabRequest>(
        json,
        (data) => ColabRequest.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<ColabRequest>>> getIncomingRequests() async {
    try {
      final json = await _getJson(ApiConstants.colabRequests);
      return _parseEnvelope<List<ColabRequest>>(json, (data) {
        final list = (data as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(ColabRequest.fromJson).toList();
      });
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabRequest>> acceptRequest({required String requestId}) async {
    try {
      final body = {'requestId': requestId};
      final response = await _httpClient.post(
        _uri(ApiConstants.colabAcceptRequest),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(json['message'] ?? 'Failed to accept request');
      }

      return _parseEnvelope<ColabRequest>(
        json,
        (data) => ColabRequest.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }

  @override
  Future<ApiResponse<ColabRequest>> rejectRequest({required String requestId}) async {
    try {
      final body = {'requestId': requestId};
      final response = await _httpClient.post(
        _uri(ApiConstants.colabRejectRequest),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(json['message'] ?? 'Failed to reject request');
      }

      return _parseEnvelope<ColabRequest>(
        json,
        (data) => ColabRequest.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(error: e.toString());
    }
  }
}
