import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trips/services/services.dart';

part 'following_trips_state.dart';

class FollowingTripsCubit extends Cubit<FollowingTripsState> {
  FollowingTripsCubit({
    required this.usersService,
    required this.authService,
    required this.tripsService,
  }) : super(const FollowingTripsState());

  final UsersService usersService;
  final AuthService authService;
  final TripsService tripsService;

  Future<void> likeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: UserLikesStatus.loadInProgress));
      await tripsService.likeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: UserLikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> dislikeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: UserLikesStatus.loadInProgress));
      await tripsService.dislikeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: UserLikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> addFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.loadInProgress));
      await tripsService.addFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.loadInProgress));
      await tripsService.deleteFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.done));
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
