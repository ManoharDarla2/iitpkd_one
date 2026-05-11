import 'package:better_auth_flutter/better_auth_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_config.dart';
import '../network/real_api_client.dart';

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
    if (error == null && result != null) {
      final (session, user) = result;
      if (user != null) {
        BetterAuth.instance.client.session = session;
        if (session != null) await saveBearerToken(session.token);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
    }

    // getSession() failed or returned no user – the BetterAuthClient
    // constructor may have already restored session+user from KVStore.
    final client = BetterAuth.instance.client;
    final cachedSession = client.session;
    final cachedUser = client.user;
    if (cachedSession != null &&
        cachedUser != null &&
        cachedSession.expiresAt.isAfter(DateTime.now())) {
      if (cachedSession.token.isNotEmpty) {
        await saveBearerToken(cachedSession.token);
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: cachedUser);
      return;
    }

    if (cachedSession != null &&
        cachedSession.expiresAt.isBefore(DateTime.now())) {
      client.session = null;
      client.user = null;
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
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
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to get Google tokens',
        );
        return;
      }

      var (user, error) = await BetterAuth.instance.client.signInWithIdToken(
        provider: SocialProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (error != null) {
        await googleSignIn.signOut();
        googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          state = state.copyWith(status: AuthStatus.unauthenticated);
          return;
        }
        googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null || googleAuth.accessToken == null) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Failed to get Google tokens',
          );
          return;
        }
        final retryResult = await BetterAuth.instance.client.signInWithIdToken(
          provider: SocialProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken!,
        );
        user = retryResult.$1;
        error = retryResult.$2;
      }

      if (error != null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
        );
      } else if (user != null) {
        final (sessionResult, _) = await BetterAuth.instance.client.getSession();
        if (sessionResult != null) {
          final (session, _) = sessionResult;
          if (session != null) {
            BetterAuth.instance.client.session = session;
            await saveBearerToken(session.token);
          }
        }
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
    BetterAuth.instance.client.session = null;
    BetterAuth.instance.client.user = null;
    await clearBearerToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig.fromEnvironment();
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);