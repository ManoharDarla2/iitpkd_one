import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ilab_connect/features/competitions/data/repositories/competition_repository.dart';
import 'package:ilab_connect/features/dashboard/view_models/providers.dart';

final competitionRepositoryProvider = Provider<CompetitionRepository>(
  (ref) => CompetitionRepository(apiClient: ref.watch(apiClientProvider)),
);
