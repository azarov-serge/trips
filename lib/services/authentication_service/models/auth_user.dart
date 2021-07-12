import 'package:equatable/equatable.dart';

/// AuthUser model
///
/// [AuthUser.empty] represents an unauthenticated user.
class AuthUser extends Equatable {
  /// {@macro user}
  const AuthUser({
    required this.id,
    this.email,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// Empty user which represents an unauthenticated user.
  static const empty = AuthUser(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == AuthUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != AuthUser.empty;

  @override
  List<Object?> get props => [id, email];
}
