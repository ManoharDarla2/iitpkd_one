import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';

/// Riverpod provider for the shuttle view model.
final shuttleViewModelProvider =
    AsyncNotifierProvider<ShuttleViewModel, List<ShuttleSchedule>>(
      ShuttleViewModel.new,
    );

/// ViewModel that manages shuttle schedule state.
///
/// Fetches schedules for the current day on initialization.
/// Exposes methods to refresh and filter schedules.
class ShuttleViewModel extends AsyncNotifier<List<ShuttleSchedule>> {
  @override
  Future<List<ShuttleSchedule>> build() async {
    final repo = ref.read(shuttleRepositoryProvider);
    final day = _currentDayName();
    return repo.getSchedules(day: day);
  }

  /// Refreshes shuttle schedules by bypassing the Hive cache.
  Future<void> refreshSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shuttleRepositoryProvider);
      return repo.getSchedules(day: _currentDayName(), forceRefresh: true);
    });
  }

  /// Filters schedules for a specific [day].
  Future<void> filterByDay(String day) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shuttleRepositoryProvider);
      return repo.getSchedules(day: day);
    });
  }

  /// Returns the current day name in lowercase (e.g., "monday").
  String _currentDayName() {
    return DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }
}
