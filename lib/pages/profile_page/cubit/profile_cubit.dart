import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trips/services/services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.usersService,
    required this.authService,
    required this.tripsService,
  }) : super(const ProfileState());

  final UsersService usersService;
  final AuthService authService;
  final TripsService tripsService;

  Future<void> getFollowers(String userId) async {
    emit(state.copyWith(
      followStatus: FollowStatus.loadInProgress,
    ));

    try {
      final List<String> followingIds = await authService.followingIds;

      emit(state.copyWith(
        followStatus: FollowStatus.done,
        followingIds: followingIds,
      ));
    } on Exception {
      emit(state.copyWith(
        followStatus: FollowStatus.error,
      ));
    }
  }

  Future<void> follow(String userId, String followerId) async {
    emit(state.copyWith(
      followStatus: FollowStatus.loadInProgress,
    ));

    try {
      await usersService.follow(userId, followerId);
      final List<String> followingIds = await authService.followingIds;

      emit(state.copyWith(
        followStatus: FollowStatus.done,
        followingIds: followingIds,
      ));
    } on Exception {
      emit(state.copyWith(
        followStatus: FollowStatus.error,
      ));
    }
  }

  Future<void> unfollow(String userId) async {
    emit(state.copyWith(
      followStatus: FollowStatus.loadInProgress,
    ));

    try {
      await usersService.removeFollowing(userId);
      final List<String> followingIds = await authService.followingIds;

      emit(
        state.copyWith(
          followStatus: FollowStatus.done,
          followingIds: followingIds,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          followStatus: FollowStatus.error,
        ),
      );
    }
  }

  Future<void> likeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: LikesStatus.loadInProgress));
      await tripsService.likeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: LikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> dislikeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: LikesStatus.loadInProgress));
      await tripsService.dislikeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: LikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> addFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: FavoritesStatus.loadInProgress));
      await tripsService.addFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: FavoritesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: FavoritesStatus.loadInProgress));
      await tripsService.deleteFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: FavoritesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      await tripsService.deleteTrip(id);
    } catch (error) {
      throw Exception(error);
    }
  }
}
