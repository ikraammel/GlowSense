import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent { const CheckAuthStatus(); }

class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested({required this.email, required this.password});
  @override List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String firstName, lastName, email, password;
  const RegisterRequested({required this.firstName, required this.lastName, required this.email, required this.password});
  @override List<Object?> get props => [firstName, lastName, email, password];
}

class LogoutRequested extends AuthEvent { const LogoutRequested(); }

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});
  @override List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token, newPassword;
  const ResetPasswordRequested({required this.token, required this.newPassword});
  @override List<Object?> get props => [token, newPassword];
}
