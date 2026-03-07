import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';
import 'package:iitpkd_one/features/faculty/data/repositories/faculty_repository.dart';

/// -- Dependency Injection Providers for the Faculty feature --

/// Provides the faculty repository with its dependencies injected.
final facultyRepositoryProvider = Provider<FacultyRepository>(
  (ref) => FacultyRepository(apiClient: ref.watch(apiClientProvider)),
);
