import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/features/competitions/data/models/competition.dart';

class CompetitionRepository {
  CompetitionRepository({required ApiClientInterface apiClient})
    : _apiClient = apiClient;

  final ApiClientInterface _apiClient;

  Future<List<Competition>> getCompetitions() async {
    final response = await _apiClient.getCompetitions();

    if (response.isError || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch competitions');
    }

    return response.data!;
  }
}
