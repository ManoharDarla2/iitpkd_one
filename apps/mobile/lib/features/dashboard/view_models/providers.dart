import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/mock_api_client.dart';
import 'package:iitpkd_one/core/services/hive_service.dart';
import 'package:iitpkd_one/features/dashboard/data/repositories/notice_repository.dart';
import 'package:iitpkd_one/features/dashboard/data/repositories/shuttle_repository.dart';

/// -- Dependency Injection Providers --
///
/// These providers wire up the app's dependencies.
/// To swap [MockApiClient] for a real implementation later,
/// simply override [apiClientProvider] in [ProviderScope].

/// Provides the API client implementation.
/// Override this in tests or when the real server is ready.
final apiClientProvider = Provider<ApiClientInterface>(
  (ref) => MockApiClient(),
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

/// Provides the notice repository with its dependencies injected.
final noticeRepositoryProvider = Provider<NoticeRepository>(
  (ref) => NoticeRepository(apiClient: ref.watch(apiClientProvider)),
);
