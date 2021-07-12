import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pedantic/pedantic.dart';
import 'package:trips/services/services.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationService authenticationService})
      : _authenticationService = authenticationService,
        super(
          authenticationService.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationService.currentUser)
              : const AppState.unauthenticated(),
        ) {
    _userSubscription = _authenticationService.authUser.listen(_onUserChanged);
  }

  final AuthenticationService _authenticationService;
  late final StreamSubscription<AuthUser> _userSubscription;

  void _onUserChanged(AuthUser authUser) => add(AppUserChanged(authUser));

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppUserChanged) {
      yield _mapUserChangedToState(event, state);
    } else if (event is AppLogoutRequested) {
      unawaited(_authenticationService.logOut());
    }
  }

  AppState _mapUserChangedToState(AppUserChanged event, AppState state) {
    return event.authUser.isNotEmpty
        ? AppState.authenticated(event.authUser)
        : const AppState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
