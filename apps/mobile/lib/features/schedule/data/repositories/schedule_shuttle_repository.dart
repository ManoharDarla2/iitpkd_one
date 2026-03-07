import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/dashboard/data/repositories/shuttle_repository.dart';

/// Route filter options for the schedule shuttle view.
enum ShuttleRouteFilter { all, nilaToSahyadri, sahyadriToNila, outside }

/// Repository that wraps [ShuttleRepository] for the schedule screen.
///
/// Adds route-based filtering on top of the existing cache-first strategy.
class ScheduleShuttleRepository {
  final ShuttleRepository _shuttleRepository;

  ScheduleShuttleRepository({required ShuttleRepository shuttleRepository})
    : _shuttleRepository = shuttleRepository;

  /// Fetches shuttle schedules for the given [day], filtered by [route].
  Future<List<ShuttleSchedule>> getSchedules({
    required String day,
    ShuttleRouteFilter route = ShuttleRouteFilter.all,
    bool forceRefresh = false,
  }) async {
    final schedules = await _shuttleRepository.getSchedules(
      day: day,
      forceRefresh: forceRefresh,
    );

    return _filterByRoute(schedules, route);
  }

  /// Filters schedules by the selected route direction.
  List<ShuttleSchedule> _filterByRoute(
    List<ShuttleSchedule> schedules,
    ShuttleRouteFilter route,
  ) {
    switch (route) {
      case ShuttleRouteFilter.all:
        return schedules;
      case ShuttleRouteFilter.nilaToSahyadri:
        return schedules
            .where(
              (s) =>
                  s.from.toLowerCase().contains('nila') &&
                  s.to.toLowerCase().contains('sahyadri'),
            )
            .toList();
      case ShuttleRouteFilter.sahyadriToNila:
        return schedules
            .where(
              (s) =>
                  s.from.toLowerCase().contains('sahyadri') &&
                  s.to.toLowerCase().contains('nila'),
            )
            .toList();
      case ShuttleRouteFilter.outside:
        return schedules.where((s) => s.isOutsideTrip).toList();
    }
  }
}
