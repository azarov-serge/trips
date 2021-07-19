part of 'profile_cubit.dart';

enum FollowStatus {
  initial,
  loadInProgress,
  done,
  error,
}

enum LikesStatus {
  initial,
  loadInProgress,
  done,
  error,
}

enum FavoritesStatus {
  initial,
  loadInProgress,
  done,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.followStatus = FollowStatus.initial,
    this.followingIds = const [],
    this.likesStatus = LikesStatus.initial,
    this.favoritesStatus = FavoritesStatus.initial,
  });

  final FollowStatus followStatus;
  final List<String> followingIds;
  final LikesStatus likesStatus;
  final FavoritesStatus favoritesStatus;

  @override
  List<Object> get props =>
      [followStatus, followingIds, likesStatus, favoritesStatus];

  ProfileState copyWith({
    FollowStatus? followStatus,
    LikesStatus? likesStatus,
    List<String>? followingIds,
    FavoritesStatus? favoritesStatus,
  }) {
    return ProfileState(
      followStatus: followStatus ?? this.followStatus,
      followingIds: followingIds ?? this.followingIds,
      likesStatus: likesStatus ?? this.likesStatus,
      favoritesStatus: favoritesStatus ?? this.favoritesStatus,
    );
  }
}
