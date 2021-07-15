import 'package:equatable/equatable.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
class User extends Equatable {
  const User({
    required this.userId,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.description = '',
  });

  /// The current user's id.
  final String userId;

  /// The current user's email address.
  final String email;

  /// The current user's display name.
  final String displayName;

  /// The current user's photo URL.
  final String? photoUrl;

  /// The current user's description.
  final String? description;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(userId: '', email: '-', displayName: '-');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props =>
      [userId, email, displayName, photoUrl, description];
}
