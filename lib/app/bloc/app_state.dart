part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

class AppState extends Equatable {
  const AppState._({
    required this.status,
    this.authUser = AuthUser.empty,
  });

  const AppState.authenticated(AuthUser authUser)
      : this._(status: AppStatus.authenticated, authUser: authUser);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final AuthUser authUser;

  @override
  List<Object> get props => [status, authUser];
}
