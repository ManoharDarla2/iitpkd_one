import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_request.dart';
import 'package:csquare_connect/features/colab/view_models/providers.dart';

final colabDetailProvider =
    FutureProvider.family<ColabItem, String>((ref, id) async {
  final repo = ref.read(colabRepositoryProvider);
  return repo.getColabDetail(id: id);
});

final colabRequestsProvider =
    FutureProvider<List<ColabRequest>>((ref) async {
  final repo = ref.read(colabRepositoryProvider);
  return repo.getIncomingRequests();
});
