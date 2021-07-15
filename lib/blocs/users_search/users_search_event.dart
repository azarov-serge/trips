import 'package:equatable/equatable.dart';

abstract class UsersSearchEvent extends Equatable {
  const UsersSearchEvent();
}

class UsersSearchEventTextChanged extends UsersSearchEvent {
  const UsersSearchEventTextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'UsersSearchEventTextChanged { text: $text }';
}
