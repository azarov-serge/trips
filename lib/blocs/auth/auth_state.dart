part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.authUser = AuthUser.empty,
  });

  const AuthState.authenticated(AuthUser authUser)
      : this._(status: AuthStatus.authenticated, authUser: authUser);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AuthUser authUser;

  @override
  List<Object> get props => [status, authUser];
}
