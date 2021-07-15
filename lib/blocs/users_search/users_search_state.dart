import 'package:equatable/equatable.dart';
import 'package:trips/services/services.dart';

abstract class UsersSearchState extends Equatable {
  const UsersSearchState();

  @override
  List<Object> get props => [];
}

class UsersSearchStateEmpty extends UsersSearchState {}

class UsersSearchStateLoading extends UsersSearchState {}

class UsersSearchStateSuccess extends UsersSearchState {
  const UsersSearchStateSuccess(this.items);

  final List<User> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class UsersSearchStateError extends UsersSearchState {
  const UsersSearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
