import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pedantic/pedantic.dart';
import 'package:trips/services/services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService})
      : super(
          authService.currentUser.isNotEmpty
              ? AuthState.authenticated(authService.currentUser)
              : const AuthState.unauthenticated(),
        ) {
    _userSubscription = authService.authUser.listen(_onUserChanged);
  }

  final AuthService authService;
  late final StreamSubscription<AuthUser> _userSubscription;

  void _onUserChanged(AuthUser authUser) => add(AuthEventUserChanged(authUser));

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthEventUserChanged) {
      yield _mapUserChangedToState(event, state);
    } else if (event is AuthEventLogoutRequested) {
      unawaited(authService.logOut());
    }
  }

  AuthState _mapUserChangedToState(
      AuthEventUserChanged event, AuthState state) {
    return event.authUser.isNotEmpty
        ? AuthState.authenticated(event.authUser)
        : const AuthState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
