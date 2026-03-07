import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';

/// Repository that manages faculty data.
///
/// Uses a network-first approach (no Hive caching) since the faculty
/// list is small and may be updated by the scraper at any time.
class FacultyRepository {
  final ApiClientInterface _apiClient;

  FacultyRepository({required ApiClientInterface apiClient})
    : _apiClient = apiClient;

  /// Fetches the lightweight list of all faculty members.
  ///
  /// Optionally filters by [department] (e.g., "Computer Science and Engineering").
  Future<List<FacultyMember>> getFacultyList({String? department}) async {
    final response = await _apiClient.getFacultyList(department: department);

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch faculty list');
    }

    return response.data!;
  }

  /// Fetches the full detailed profile of a faculty member by [slug].
  Future<FacultyDetail> getFacultyDetail({required String slug}) async {
    final response = await _apiClient.getFacultyDetail(slug: slug);

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch faculty detail');
    }

    return response.data!;
  }
}
