import 'package:csquare_connect/core/network/api_client_interface.dart';
import 'package:csquare_connect/features/competitions/data/models/competition.dart';

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
