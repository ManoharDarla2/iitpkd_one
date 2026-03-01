import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

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

  /// GET /api/v1/notices/today
  ///
  /// Fetches today's notices. Always fresh, not cached.
  Future<ApiResponse<List<Notice>>> getTodayNotices();

  /// GET /api/v1/notices?date={dateFilter}
  ///
  /// Fetches notices with optional date filter (up to one week of history).
  Future<ApiResponse<List<Notice>>> getNotices({String? dateFilter});
}
