import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trips/services/services.dart';

part 'following_trips_state.dart';

class FollowingTripsCubit extends Cubit<FollowingTripsState> {
  FollowingTripsCubit({
    required this.usersService,
    required this.authService,
    required this.tripsServices,
  }) : super(const FollowingTripsState());

  final UsersService usersService;
  final AuthService authService;
  final TripsService tripsServices;

  Future<void> likeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: UserLikesStatus.loadInProgress));
      await tripsServices.likeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: UserLikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> dislikeTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(likesStatus: UserLikesStatus.loadInProgress));
      await tripsServices.dislikeTrip(tripId, userId);
      emit(state.copyWith(likesStatus: UserLikesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> addFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.loadInProgress));
      await tripsServices.addFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteFavoriteTrip(String tripId, String userId) async {
    try {
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.loadInProgress));
      await tripsServices.deleteFavoriteTrip(tripId, userId);
      emit(state.copyWith(favoritesStatus: UserFavoritesStatus.done));
    } catch (error) {
      throw Exception(error);
    }
  }
}
