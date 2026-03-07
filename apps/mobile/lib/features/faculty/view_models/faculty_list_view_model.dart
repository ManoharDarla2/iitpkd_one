import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';
import 'package:iitpkd_one/features/faculty/view_models/providers.dart';

/// Riverpod provider for the faculty list view model.
final facultyListViewModelProvider =
    AsyncNotifierProvider<FacultyListViewModel, List<FacultyMember>>(
      FacultyListViewModel.new,
    );

/// ViewModel that manages the faculty list state.
///
/// Loads all faculty on initialization.
/// Supports filtering by department and pull-to-refresh.
class FacultyListViewModel extends AsyncNotifier<List<FacultyMember>> {
  /// All faculty members fetched from the API (unfiltered).
  List<FacultyMember> _allFaculty = [];

  /// Currently selected department filter (null = all).
  String? _selectedDepartment;

  /// Returns the currently selected department filter.
  String? get selectedDepartment => _selectedDepartment;

  /// Returns the distinct list of departments from the loaded data.
  List<String> get departments {
    final depts = _allFaculty.map((f) => f.department).toSet().toList();
    depts.sort();
    return depts;
  }

  @override
  Future<List<FacultyMember>> build() async {
    final repo = ref.read(facultyRepositoryProvider);
    _allFaculty = await repo.getFacultyList();
    return _applyFilter(_allFaculty);
  }

  /// Filters the faculty list by [department].
  /// Pass null to show all departments.
  void filterByDepartment(String? department) {
    _selectedDepartment = department;
    final current = _allFaculty;
    if (current.isNotEmpty) {
      state = AsyncValue.data(_applyFilter(current));
    }
  }

  /// Refreshes the faculty list from the API.
  Future<void> refreshFacultyList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(facultyRepositoryProvider);
      _allFaculty = await repo.getFacultyList();
      return _applyFilter(_allFaculty);
    });
  }

  /// Applies the department filter to the full list.
  List<FacultyMember> _applyFilter(List<FacultyMember> faculty) {
    if (_selectedDepartment == null) return faculty;
    return faculty
        .where((f) => f.department == _selectedDepartment)
        .toList();
  }
}
