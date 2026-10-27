import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'app_providers.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _authRepository.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final cachedUserMap = await _authRepository.getCachedUser();
      if (cachedUserMap != null) {
        final user = UserModel.fromJson(cachedUserMap);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }

      // Refresh profile in background
      final user = await _authRepository.getProfile();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'USD',
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        currency: currency,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
