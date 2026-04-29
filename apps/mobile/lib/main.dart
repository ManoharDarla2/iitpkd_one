import 'package:better_auth_flutter/better_auth_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iitpkd_one/app.dart';
import 'package:iitpkd_one/core/auth/auth_config.dart';
import 'package:iitpkd_one/core/services/hive_service.dart';
import 'package:iitpkd_one/features/dashboard/view_models/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');

  // Initialize Hive for local caching (shuttle schedules).
  final hiveService = HiveService();
  await hiveService.init();

  final authConfig = AuthConfig.fromEnvironment();
  BetterAuth.init(baseUrl: Uri.parse(authConfig.baseUrl));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: AuthConfigProvider(
        config: authConfig,
        child: const App(),
      ),
    ),
  );
}
