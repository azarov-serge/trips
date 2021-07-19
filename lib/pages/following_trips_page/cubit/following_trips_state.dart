part of 'following_trips_cubit.dart';

enum UserFollowStatus {
  initial,
  loadInProgress,
  done,
  error,
}

enum UserLikesStatus {
  initial,
  loadInProgress,
  done,
  error,
}

enum UserFavoritesStatus {
  initial,
  loadInProgress,
  done,
  error,
}

class FollowingTripsState extends Equatable {
  const FollowingTripsState({
    this.followStatus = UserFollowStatus.initial,
    this.likesStatus = UserLikesStatus.initial,
    this.favoritesStatus = UserFavoritesStatus.initial,
  });

  final UserFollowStatus followStatus;
  final UserLikesStatus likesStatus;
  final UserFavoritesStatus favoritesStatus;

  @override
  List<Object> get props => [followStatus, likesStatus, favoritesStatus];

  FollowingTripsState copyWith({
    UserFollowStatus? followStatus,
    UserLikesStatus? likesStatus,
    UserFavoritesStatus? favoritesStatus,
  }) {
    return FollowingTripsState(
      followStatus: followStatus ?? this.followStatus,
      likesStatus: likesStatus ?? this.likesStatus,
      favoritesStatus: favoritesStatus ?? this.favoritesStatus,
    );
  }
}
