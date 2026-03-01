import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';

/// Repository that manages notice data.
///
/// Notices are highly dynamic (change every minute/second)
/// and should NOT be cached with Hive.
class NoticeRepository {
  final ApiClientInterface _apiClient;

  NoticeRepository({required ApiClientInterface apiClient})
    : _apiClient = apiClient;

  /// Fetches today's notices. Always a fresh network call.
  Future<List<Notice>> getTodayNotices() async {
    final response = await _apiClient.getTodayNotices();

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch today\'s notices');
    }

    return response.data!;
  }

  /// Fetches notices with an optional [dateFilter] for history.
  ///
  /// The server retains notices for up to one week.
  Future<List<Notice>> getNotices({String? dateFilter}) async {
    final response = await _apiClient.getNotices(dateFilter: dateFilter);

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch notices');
    }

    return response.data!;
  }
}
