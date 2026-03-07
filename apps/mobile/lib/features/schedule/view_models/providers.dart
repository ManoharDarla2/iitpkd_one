import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';
import 'package:iitpkd_one/features/schedule/data/repositories/mess_repository.dart';
import 'package:iitpkd_one/features/schedule/data/repositories/schedule_shuttle_repository.dart';

/// -- Dependency Injection Providers for the Schedule feature --

/// Provides the mess repository with its dependencies injected.
final messRepositoryProvider = Provider<MessRepository>(
  (ref) => MessRepository(
    apiClient: ref.watch(apiClientProvider),
    hiveService: ref.watch(hiveServiceProvider),
  ),
);

/// Provides the schedule shuttle repository with its dependencies injected.
final scheduleShuttleRepositoryProvider = Provider<ScheduleShuttleRepository>(
  (ref) => ScheduleShuttleRepository(
    shuttleRepository: ref.watch(shuttleRepositoryProvider),
  ),
);
