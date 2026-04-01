import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/competitions/data/repositories/competition_repository.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';

final competitionRepositoryProvider = Provider<CompetitionRepository>(
  (ref) => CompetitionRepository(apiClient: ref.watch(apiClientProvider)),
);
