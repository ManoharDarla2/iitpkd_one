import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iitpkd_one/core/constants/api_constants.dart';

class AuthConfig {
  final String baseUrl;
  final String? googleClientId;

  const AuthConfig({required this.baseUrl, this.googleClientId});

  factory AuthConfig.fromEnvironment() {
    final baseUrl = ApiConstants.baseUrl;

    return AuthConfig(
      baseUrl: baseUrl,
      googleClientId: dotenv.env['GOOGLE_CLIENT_ID'],
    );
  }

  GoogleSignIn? get googleSignIn {
    if (googleClientId == null || googleClientId!.isEmpty) return null;
    return GoogleSignIn(serverClientId: googleClientId);
  }
}

class AuthConfigProvider extends InheritedWidget {
  final AuthConfig config;

  const AuthConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(AuthConfigProvider oldWidget) {
    return config.baseUrl != oldWidget.config.baseUrl ||
        config.googleClientId != oldWidget.config.googleClientId;
  }

  static AuthConfig of(BuildContext context) {
    final provider = context
        .getInheritedWidgetOfExactType<AuthConfigProvider>();
    return provider?.config ?? AuthConfig.fromEnvironment();
  }
}
