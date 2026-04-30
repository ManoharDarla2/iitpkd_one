import 'package:ilab_connect/core/network/api_response.dart';
import 'package:ilab_connect/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:ilab_connect/features/competitions/data/models/competition.dart';
import 'package:ilab_connect/features/faculty/data/models/faculty_detail.dart';
import 'package:ilab_connect/features/faculty/data/models/faculty_member.dart';
import 'package:ilab_connect/features/schedule/data/models/meal_day.dart';
import 'package:ilab_connect/features/schedule/data/models/mess_menu.dart';
import 'package:ilab_connect/features/schedule/data/models/mess_metadata.dart';
import 'package:ilab_connect/features/schedule/data/models/shuttle_metadata.dart';
import 'package:ilab_connect/features/search/data/models/search_result.dart';

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
}
