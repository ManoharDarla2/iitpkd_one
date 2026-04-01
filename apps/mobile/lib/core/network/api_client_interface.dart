import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/competitions/data/models/competition.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_metadata.dart';
import 'package:iitpkd_one/features/schedule/data/models/shuttle_metadata.dart';
import 'package:iitpkd_one/features/search/data/models/search_result.dart';

/// Abstract interface defining all API endpoints.
///
/// Implementations include [MockApiClient] (for development) and
/// a future [RealApiClient] (when the backend is ready).
/// This allows swapping via Riverpod provider overrides without
/// touching any UI or ViewModel logic.
abstract interface class ApiClientInterface {
  /// GET /api/v1/shuttles?day={day}
  ///
  /// Fetches shuttle schedules, optionally filtered by day.
  Future<ApiResponse<List<ShuttleSchedule>>> getShuttleSchedules({String? day});

  /// GET /api/v1/shuttles/metadata
  ///
  /// Returns metadata (updated_at, version) for cache invalidation.
  Future<ApiResponse<ShuttleMetadata>> getShuttleMetadata();

  /// GET /api/v1/notices/today
  ///
  /// Fetches today's notices. Always fresh, not cached.
  Future<ApiResponse<List<Notice>>> getTodayNotices();

  /// GET /api/v1/notices?date={dateFilter}
  ///
  /// Fetches notices with optional date filter (up to one week of history).
  Future<ApiResponse<List<Notice>>> getNotices({String? dateFilter});

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
