import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/real_api_client.dart';
import 'package:iitpkd_one/core/services/hive_service.dart';
import 'package:iitpkd_one/features/dashboard/data/repositories/shuttle_repository.dart';

/// -- Dependency Injection Providers --

/// Provides the API client implementation.
final apiClientProvider = Provider<ApiClientInterface>(
  (ref) => RealApiClient(),
);

/// Provides the Hive service for local caching.
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

/// Provides the shuttle repository with its dependencies injected.
final shuttleRepositoryProvider = Provider<ShuttleRepository>(
  (ref) => ShuttleRepository(
    apiClient: ref.watch(apiClientProvider),
    hiveService: ref.watch(hiveServiceProvider),
  ),
);
