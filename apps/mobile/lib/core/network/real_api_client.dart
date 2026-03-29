import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iitpkd_one/core/constants/api_constants.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/core/network/mock_api_client.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_metadata.dart';
import 'package:iitpkd_one/features/schedule/data/models/shuttle_metadata.dart';
import 'package:iitpkd_one/features/search/data/models/search_result.dart';

class RealApiClient implements ApiClientInterface {
  RealApiClient({http.Client? httpClient, MockApiClient? mockClient})
    : _httpClient = httpClient ?? http.Client(),
      _mockClient = mockClient ?? MockApiClient();

  final http.Client _httpClient;
  final MockApiClient _mockClient;

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
    final response = await _httpClient.get(
      _uri(path, queryParameters),
      headers: {'Accept': 'application/json'},
    );

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
  Future<ApiResponse<List<Notice>>> getTodayNotices() {
    return _mockClient.getTodayNotices();
  }

  @override
  Future<ApiResponse<List<Notice>>> getNotices({String? dateFilter}) {
    return _mockClient.getNotices(dateFilter: dateFilter);
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
}
