import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:csquare_connect/features/colab/data/models/colab_item.dart';
import 'package:csquare_connect/features/colab/data/models/colab_type.dart';
import 'package:csquare_connect/features/colab/data/repositories/colab_repository.dart';
import 'package:csquare_connect/features/colab/view_models/providers.dart';

final colabViewModelProvider =
    AsyncNotifierProvider<ColabViewModel, List<ColabItem>>(
      ColabViewModel.new,
    );

class ColabViewModel extends AsyncNotifier<List<ColabItem>> {
  String _searchQuery = '';
  ColabType? _typeFilter;
  List<ColabItem> _allColabs = const [];

  String get searchQuery => _searchQuery;
  ColabType? get typeFilter => _typeFilter;

  @override
  Future<List<ColabItem>> build() async {
    return _fetchColabs();
  }

  Future<void> refreshColabs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchColabs(forceRefresh: true);
    });
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    if (state.isLoading) return;
    state = AsyncValue.data(_applyFilters());
  }

  void clearSearch() {
    _searchQuery = '';
    if (state.isLoading) return;
    state = AsyncValue.data(_applyFilters());
  }

  void filterByType(ColabType? type) {
    _typeFilter = type;
    if (state.isLoading) return;
    state = AsyncValue.data(_applyFilters());
  }

  ColabRepository _repository() => ref.read(colabRepositoryProvider);

  Future<List<ColabItem>> _fetchColabs({bool forceRefresh = false}) async {
    final repo = _repository();
    final data = await repo.getColabs(forceRefresh: forceRefresh);
    _allColabs = data;
    return _applyFilters();
  }

  List<ColabItem> _applyFilters() {
    var items = _allColabs;
    if (_typeFilter != null) {
      items = items.where((item) => item.type == _typeFilter).toList();
    }
    return _applySearch(items);
  }

  List<ColabItem> _applySearch(List<ColabItem> items) {
    if (_searchQuery.isEmpty) return items;
    final normalized = _searchQuery.toLowerCase();
    return items.where((item) {
      final title = item.title.toLowerCase();
      final description = item.description.toLowerCase();
      final requirements = item.requirements.toLowerCase();
      return title.contains(normalized) ||
          description.contains(normalized) ||
          requirements.contains(normalized);
    }).toList();
  }
}
