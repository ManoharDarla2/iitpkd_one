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

    // Tier 1: Try cookie-based session restore from server
    final (result, error) = await BetterAuth.instance.client.getSession();
    if (error == null && result != null) {
      final (session, user) = result;
      if (user != null) {
        BetterAuth.instance.client.session = session;
        if (session != null) {
          await saveBearerToken(session.token);
          await saveUserJson(user.toJson());
          await saveSessionJson(session.toJson());
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
    }

    // Tier 2: Restore from our own SharedPreferences storage
    final userJson = await getUserJson();

    if (userJson != null) {
      try {
        final user = User.fromJson(userJson);
        final sessionJson = await getSessionJson();
        if (sessionJson != null) {
          final session = Session.fromJson(sessionJson);
          BetterAuth.instance.client.session = session;
          await saveBearerToken(session.token);
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      } catch (_) {
        await clearAuthData();
      }
    }

    // Tier 3: Try BetterAuthClient KVStore cache (may have user but no session)
    final client = BetterAuth.instance.client;
    if (client.user != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: client.user);
      return;
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
            await saveUserJson(user.toJson());
            await saveSessionJson(session.toJson());
          }
        } else {
          // Even without session, persist user for profile display
          await saveUserJson(user.toJson());
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
    await clearAuthData();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig.fromEnvironment();
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);