import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/schedule/data/repositories/schedule_shuttle_repository.dart';
import 'package:iitpkd_one/features/schedule/view_models/providers.dart';

/// Riverpod provider for the schedule shuttle view model.
final scheduleShuttleViewModelProvider = AsyncNotifierProvider<
  ScheduleShuttleViewModel,
  List<ShuttleSchedule>
>(ScheduleShuttleViewModel.new);

/// ViewModel that manages shuttle schedule state for the Schedule screen.
///
/// Supports day selection (Today / Tomorrow) and route filtering.
class ScheduleShuttleViewModel extends AsyncNotifier<List<ShuttleSchedule>> {
  /// Whether viewing today or tomorrow. true = today, false = tomorrow.
  bool _isToday = true;

  /// Current route filter.
  ShuttleRouteFilter _routeFilter = ShuttleRouteFilter.all;

  /// Current day selection.
  bool get isToday => _isToday;

  /// Current route filter.
  ShuttleRouteFilter get routeFilter => _routeFilter;

  @override
  Future<List<ShuttleSchedule>> build() async {
    return _fetchSchedules();
  }

  /// Switches between Today and Tomorrow.
  Future<void> selectDay({required bool isToday}) async {
    _isToday = isToday;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSchedules);
  }

  /// Changes the route filter.
  Future<void> selectRoute(ShuttleRouteFilter route) async {
    _routeFilter = route;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSchedules);
  }

  /// Refreshes shuttle data from the API (bypasses cache).
  Future<void> refreshSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(scheduleShuttleRepositoryProvider);
      return repo.getSchedules(
        day: _dayName(),
        route: _routeFilter,
        forceRefresh: true,
      );
    });
  }

  Future<List<ShuttleSchedule>> _fetchSchedules() async {
    final repo = ref.read(scheduleShuttleRepositoryProvider);
    return repo.getSchedules(day: _dayName(), route: _routeFilter);
  }

  /// Returns the day name for the current selection.
  String _dayName() {
    final date = _isToday
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));
    return DateFormat('EEEE').format(date).toLowerCase();
  }
}
