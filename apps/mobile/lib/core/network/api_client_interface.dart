import 'package:csquare_connect/core/network/api_response.dart';
import 'package:csquare_connect/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:csquare_connect/features/competitions/data/models/competition.dart';
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

/// Abstract interface defining all API endpoints.
abstract interface class ApiClientInterface {
  /// GET /api/v1/shuttles?day={day}
  ///
  /// Fetches shuttle schedules, optionally filtered by day.
  Future<ApiResponse<List<ShuttleSchedule>>> getShuttleSchedules({String? day});

  /// GET /api/v1/shuttles/metadata
  ///
  /// Returns metadata (updated_at, version) for cache invalidation.
  Future<ApiResponse<ShuttleMetadata>> getShuttleMetadata();

  /// GET /api/v1/mess/menu
  ///
  /// Fetches the full 14-day rotating mess menu. Ideal for local caching.
  Future<ApiResponse<MessMenu>> getMessMenu();

  /// GET /api/v1/mess/menu/today
  ///
  /// The backend calculates odd/even week and returns today's meals.
  Future<ApiResponse<MealDay>> getMessMenuToday();

  /// GET /api/v1/mess/metadata
  ///
  /// Returns an updated_at timestamp for cache invalidation.
  Future<ApiResponse<MessMetadata>> getMessMetadata();

  /// GET /api/v1/faculty
  ///
  /// Fetches the lightweight list of all faculty members.
  /// Supports optional [department] filter (e.g., "CSE").
  Future<ApiResponse<List<FacultyMember>>> getFacultyList({String? department});

  /// GET /api/v1/faculty/:slug
  ///
  /// Fetches the full detailed profile of a specific faculty member.
  Future<ApiResponse<FacultyDetail>> getFacultyDetail({required String slug});

  // -- Search endpoints --

  /// GET /api/v1/search?q={query}&category={category}&limit={limit}
  ///
  /// Unified search across all campus resource categories.
  /// [query] is the search term (required, min 1 character).
  /// [category] filters results to a single category (optional).
  /// [limit] caps the number of results (default 20).
  Future<ApiResponse<SearchResult>> search({
    required String query,
    String? category,
    int? limit,
  });

  /// GET /api/v1/search/suggestions?q={query}
  ///
  /// Lightweight prefix-based autocomplete suggestions.
  /// Returns a short list of matching terms as the user types.
  Future<ApiResponse<List<String>>> getSearchSuggestions({
    required String query,
  });

  /// GET /api/v1/competitions
  ///
  /// Fetches currently available competition opportunities.
  Future<ApiResponse<List<Competition>>> getCompetitions();

  // -- Colab endpoints --

  /// GET /api/v1/colabs
  ///
  /// Lists colabs with optional filters.
  Future<ApiResponse<List<ColabItem>>> getColabs({
    ColabType? type,
    bool? isActive,
    String? createdBy,
  });

  /// GET /api/v1/colabs/:id
  ///
  /// Get colab detail by ID.
  Future<ApiResponse<ColabItem>> getColabDetail({required String id});

  /// POST /api/v1/colabs
  ///
  /// Create a new colab with optional image upload.
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
  });

  /// PATCH /api/v1/colabs/:id
  ///
  /// Update an existing colab.
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
  });

  /// DELETE /api/v1/colabs/:id
  ///
  /// Delete a colab.
  Future<ApiResponse<Map<String, dynamic>>> deleteColab({required String id});

  /// POST /api/v1/colabs/requests/join
  ///
  /// Create a join request for a colab.
  Future<ApiResponse<ColabRequest>> createJoinRequest({
    required String colabId,
    String? message,
    DateTime? expiresAt,
  });

  /// POST /api/v1/colabs/requests/invite
  ///
  /// Create an invite request for a colab.
  Future<ApiResponse<ColabRequest>> createInviteRequest({
    required String colabId,
    required String recipientId,
    String? message,
    DateTime? expiresAt,
  });

  /// GET /api/v1/colabs/requests
  ///
  /// List incoming requests for the authenticated user.
  Future<ApiResponse<List<ColabRequest>>> getIncomingRequests();

  /// POST /api/v1/colabs/requests/accept
  ///
  /// Accept a request.
  Future<ApiResponse<ColabRequest>> acceptRequest({required String requestId});

  /// POST /api/v1/colabs/requests/reject
  ///
  /// Reject a request.
  Future<ApiResponse<ColabRequest>> rejectRequest({required String requestId});
}
