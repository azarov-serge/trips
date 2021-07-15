import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';
export 'users_search_event.dart';
export 'users_search_state.dart';

class UsersSearchBloc extends Bloc<UsersSearchEvent, UsersSearchState> {
  UsersSearchBloc({required this.usersService})
      : super(UsersSearchStateEmpty());

  final UsersService usersService;

  @override
  Stream<Transition<UsersSearchEvent, UsersSearchState>> transformEvents(
    Stream<UsersSearchEvent> events,
    Stream<Transition<UsersSearchEvent, UsersSearchState>> Function(
      UsersSearchEvent event,
    )
        transitionFn,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }

  @override
  Stream<UsersSearchState> mapEventToState(UsersSearchEvent event) async* {
    if (event is UsersSearchEventTextChanged) {
      final searchTerm = event.text;
      if (searchTerm.isEmpty) {
        yield UsersSearchStateEmpty();
      } else {
        yield UsersSearchStateLoading();
        try {
          final List<User> results =
              await usersService.searchUserByName(searchTerm);
          yield UsersSearchStateSuccess(results);
        } catch (error) {
          yield UsersSearchStateError('Error: ${error.toString()}');
        }
      }
    }
  }
}
