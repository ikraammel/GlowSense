import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _api;
  final LocalStorageService _storage;

  AuthBloc({required ApiService api, required LocalStorageService storage})
      : _api = api, _storage = storage, super(const AuthInitial()) {
    on<CheckAuthStatus>(_checkAuth);
    on<LoginRequested>(_login);
    on<RegisterRequested>(_register);
    on<LogoutRequested>(_logout);
    on<ForgotPasswordRequested>(_forgotPassword);
    on<ResetPasswordRequested>(_resetPassword);
  }

  Future<void> _checkAuth(CheckAuthStatus e, Emitter<AuthState> emit) async {
    final token = _storage.getAccessToken();
    if (token == null || token.isEmpty) { 
      emit(const AuthUnauthenticated()); 
      return; 
    }
    try {
      final user = await _api.getProfile();
      emit(AuthAuthenticated(user: user, needsOnboarding: !user.onboardingCompleted));
    } catch (_) { 
      emit(const AuthUnauthenticated()); 
    }
  }

  Future<void> _login(LoginRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final auth = await _api.login(e.email, e.password);
      await _storage.saveTokens(auth.accessToken, auth.refreshToken);
      emit(AuthAuthenticated(user: auth.user, needsOnboarding: !auth.user.onboardingCompleted));
    } catch (err) {
      emit(AuthFailure(message: err.toString()));
    }
  }

  Future<void> _register(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final auth = await _api.register(e.firstName, e.lastName, e.email, e.password);
      await _storage.saveTokens(auth.accessToken, auth.refreshToken);
      emit(AuthAuthenticated(user: auth.user, needsOnboarding: true));
    } catch (err) { 
      emit(AuthFailure(message: err.toString())); 
    }
  }

  Future<void> _logout(LogoutRequested e, Emitter<AuthState> emit) async {
    await _storage.clearTokens();
    emit(const AuthUnauthenticated());
  }

  Future<void> _forgotPassword(ForgotPasswordRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _api.forgotPassword(e.email);
      emit(const ForgotPasswordSuccess());
    } catch (err) { 
      emit(AuthFailure(message: err.toString())); 
    }
  }

  Future<void> _resetPassword(ResetPasswordRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _api.resetPassword(e.token, e.newPassword);
      // Emission de l'état ResetPasswordSuccess au lieu de AuthAuthenticated pour permettre l'affichage du message et la navigation vers login
      emit(const ResetPasswordSuccess());
    } catch (err) {
      emit(AuthFailure(message: err.toString()));
    }
  }
}
