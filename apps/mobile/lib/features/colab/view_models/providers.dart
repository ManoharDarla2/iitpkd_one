import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/colab/data/repositories/colab_repository.dart';
import 'package:csquare_connect/features/dashboard/view_models/providers.dart';

final colabRepositoryProvider = Provider<ColabRepository>(
  (ref) => ColabRepository(
    apiClient: ref.watch(apiClientProvider),
    hiveService: ref.watch(hiveServiceProvider),
  ),
);
