part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthEventLogoutRequested extends AuthEvent {}

class AuthEventUserChanged extends AuthEvent {
  @visibleForTesting
  const AuthEventUserChanged(this.authUser);

  final AuthUser authUser;

  @override
  List<Object> get props => [authUser];
}
