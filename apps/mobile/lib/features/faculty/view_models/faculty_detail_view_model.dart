import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';
import 'package:iitpkd_one/features/faculty/view_models/providers.dart';

/// Family provider for faculty detail, keyed by slug.
///
/// Each slug gets its own independent async state, so navigating
/// between different faculty profiles doesn't share loading states.
/// Uses [FutureProvider.family] for simplicity with refresh support.
final facultyDetailViewModelProvider =
    FutureProvider.family<FacultyDetail, String>((ref, slug) async {
  final repo = ref.read(facultyRepositoryProvider);
  return repo.getFacultyDetail(slug: slug);
});
