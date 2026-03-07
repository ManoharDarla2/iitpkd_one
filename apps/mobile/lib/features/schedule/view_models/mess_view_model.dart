import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';
import 'package:iitpkd_one/features/schedule/view_models/providers.dart';

/// Riverpod provider for the mess view model.
final messViewModelProvider =
    AsyncNotifierProvider<MessViewModel, MessMenu>(MessViewModel.new);

/// ViewModel that manages mess menu state for the Schedule screen.
///
/// Loads the full 14-day menu on initialization.
/// Provides helpers to calculate the current week type and retrieve
/// meals for a specific day.
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

  /// Returns meals for a specific [weekType] and [day].
  MealDay? getMealsForDay(String weekType, String day) {
    return state.value?.getMealsForDay(weekType, day);
  }

  /// Calculates the current week type ("odd" or "even").
  ///
  /// Uses Jan 5, 2026 as the reference "odd" week start date.
  static String currentWeekType() {
    final reference = DateTime(2026, 1, 5);
    final weeksDiff = DateTime.now().difference(reference).inDays ~/ 7;
    return weeksDiff.isEven ? 'odd' : 'even';
  }

  /// Returns the current day name in lowercase.
  static String currentDayName() {
    return DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }
}
