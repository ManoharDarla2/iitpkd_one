import 'package:better_auth_flutter/better_auth_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_config.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(status: AuthStatus.initial);
  }

  AuthConfig get _config => ref.read(authConfigProvider);

  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    final (result, error) = await BetterAuth.instance.client.getSession();
    if (error != null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } else if (result != null) {
      final (_, user) = result;
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    if (_config.googleSignIn == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google Sign-In not configured',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final googleSignIn = _config.googleSignIn!;
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to get Google tokens',
        );
        return;
      }

      final (user, error) = await BetterAuth.instance.client.signInWithIdToken(
        provider: SocialProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (error != null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
        );
      } else if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    await BetterAuth.instance.client.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig.fromEnvironment();
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);