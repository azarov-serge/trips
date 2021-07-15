part of 'profile_cubit.dart';

enum FollowStatus {
  initial,
  followInProgress,
  done,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = FollowStatus.initial,
    this.following = const [],
  });

  final FollowStatus status;
  final List following;

  @override
  List<Object> get props => [status, following];

  ProfileState copyWith({
    FollowStatus? status,
    List? following,
  }) {
    return ProfileState(
      status: status ?? this.status,
      following: following ?? this.following,
    );
  }
}
