import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/competitions/data/models/competition.dart';
import 'package:iitpkd_one/features/competitions/view_models/providers.dart';

final competitionViewModelProvider =
    AsyncNotifierProvider<CompetitionViewModel, List<Competition>>(
      CompetitionViewModel.new,
    );

class CompetitionViewModel extends AsyncNotifier<List<Competition>> {
  @override
  Future<List<Competition>> build() async {
    final repo = ref.read(competitionRepositoryProvider);
    final competitions = await repo.getCompetitions();
    competitions.sort((a, b) => a.deadline.compareTo(b.deadline));
    return competitions;
  }

  Future<void> refreshCompetitions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(competitionRepositoryProvider);
      final competitions = await repo.getCompetitions();
      competitions.sort((a, b) => a.deadline.compareTo(b.deadline));
      return competitions;
    });
  }
}
