import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trips/services/services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.usersService,
    required this.authService,
  }) : super(const ProfileState());

  final UsersService usersService;
  final AuthService authService;

  Future<void> getFollowers(String userId) async {
    emit(state.copyWith(
      status: FollowStatus.followInProgress,
      following: state.following,
    ));

    try {
      final followingData = await authService.following;

      final following = followingData.docs != null
          ? followingData.docs.map((doc) => doc['userId']).toList()
          : [];

      emit(
        state.copyWith(
          status: FollowStatus.done,
          following: following,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: FollowStatus.error,
          following: state.following,
        ),
      );
    }
  }

  Future<void> follow(String userId, String followerId) async {
    emit(state.copyWith(
      status: FollowStatus.followInProgress,
      following: state.following,
    ));

    try {
      await usersService.follow(userId, followerId);
      final followingData = await authService.following;

      final following = followingData.docs != null
          ? followingData.docs.map((doc) => doc['userId']).toList()
          : [];

      emit(
        state.copyWith(
          status: FollowStatus.done,
          following: following,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: FollowStatus.error,
          following: state.following,
        ),
      );
    }
  }

  Future<void> unfollow(String userId) async {
    emit(state.copyWith(
      status: FollowStatus.followInProgress,
      following: state.following,
    ));

    try {
      await usersService.removeFollowing(userId);
      final followingData = await authService.following;

      final following = followingData.docs != null
          ? followingData.docs.map((doc) => doc['userId']).toList()
          : [];
      emit(
        state.copyWith(
          status: FollowStatus.done,
          following: following,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: FollowStatus.error,
          following: state.following,
        ),
      );
    }
  }
}
