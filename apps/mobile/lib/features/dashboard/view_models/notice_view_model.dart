import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';

/// Riverpod provider for the notice view model.
final noticeViewModelProvider =
    AsyncNotifierProvider<NoticeViewModel, List<Notice>>(NoticeViewModel.new);

/// ViewModel that manages real-time notice/update state.
///
/// Fetches today's notices on initialization.
/// Supports refresh and dismissing individual notices.
class NoticeViewModel extends AsyncNotifier<List<Notice>> {
  /// Set of notice IDs that the user has dismissed locally.
  final Set<String> _dismissedIds = {};

  @override
  Future<List<Notice>> build() async {
    final repo = ref.read(noticeRepositoryProvider);
    final notices = await repo.getTodayNotices();
    return _applyDismissals(notices);
  }

  /// Refreshes today's notices from the API.
  Future<void> refreshNotices() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noticeRepositoryProvider);
      final notices = await repo.getTodayNotices();
      return _applyDismissals(notices);
    });
  }

  /// Dismisses a notice by [id] from the current view.
  /// This is a local-only action; the notice is not deleted on the server.
  void dismissNotice(String id) {
    _dismissedIds.add(id);
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.where((n) => n.id != id).toList());
    }
  }

  /// Filters out dismissed notices.
  List<Notice> _applyDismissals(List<Notice> notices) {
    if (_dismissedIds.isEmpty) return notices;
    return notices.where((n) => !_dismissedIds.contains(n.id)).toList();
  }
}
