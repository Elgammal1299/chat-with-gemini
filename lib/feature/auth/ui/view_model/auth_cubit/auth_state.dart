part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthRegesterLoading extends AuthState {}

final class AuthRegesterSuccess extends AuthState {
  final User user;

  AuthRegesterSuccess(this.user);
}

final class AuthRegesterError extends AuthState {
  final String error;

  AuthRegesterError(this.error);
}

final class AuthLoginLoading extends AuthState {}

final class AuthLoginSuccess extends AuthState {
  final User user;

  AuthLoginSuccess(this.user);
}

final class AuthLoginrError extends AuthState {
  final String error;

  AuthLoginrError(this.error);
}
