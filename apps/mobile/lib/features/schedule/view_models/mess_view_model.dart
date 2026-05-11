import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:csquare_connect/features/schedule/data/models/meal_day.dart';
import 'package:csquare_connect/features/schedule/data/models/mess_menu.dart';
import 'package:csquare_connect/features/schedule/view_models/providers.dart';

/// Riverpod provider for the mess view model.
final messViewModelProvider = AsyncNotifierProvider<MessViewModel, MessMenu>(
  MessViewModel.new,
);

/// ViewModel that manages mess menu state for the Schedule screen.
///
/// Loads the full 14-day menu on initialization.
/// Determines the current week type from the server (via metadata), with
/// a local fallback calculation if no server value is cached yet.
class MessViewModel extends AsyncNotifier<MessMenu> {
  @override
  Future<MessMenu> build() async {
    final repo = ref.read(messRepositoryProvider);
    return repo.getFullMenu();
  }

  /// Refreshes the mess menu from the API (bypasses cache).
  Future<void> refreshMenu() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(messRepositoryProvider);
      return repo.getFullMenu(forceRefresh: true);
    });
  }

  /// Returns the current week type ("odd" or "even").
  ///
  /// Uses the server-determined value from cached metadata if available,
  /// otherwise falls back to the local calculation.
  String get currentWeekType {
    final repo = ref.read(messRepositoryProvider);
    return repo.getCachedWeekType();
  }

  /// Returns meals for a specific [weekType] and [day].
  MealDay? getMealsForDay(String weekType, String day) {
    return state.value?.getMealsForDay(weekType, day);
  }

  /// Returns the current day name in lowercase.
  static String currentDayName() {
    return DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }
}
