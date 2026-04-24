import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class ForgotPasswordSuccess extends AuthState { const ForgotPasswordSuccess(); }
class ResetPasswordSuccess extends AuthState { const ResetPasswordSuccess(); }

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool needsOnboarding;
  const AuthAuthenticated({required this.user, this.needsOnboarding = false});
  @override List<Object?> get props => [user, needsOnboarding];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
  @override List<Object?> get props => [message];
}
