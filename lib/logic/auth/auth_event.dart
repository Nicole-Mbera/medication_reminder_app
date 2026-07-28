import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String healthCondition;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.healthCondition = 'Diabetes',
  });

  @override
  List<Object?> get props =>
      [email, password, fullName, phoneNumber, healthCondition];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {}
