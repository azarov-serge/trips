import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class TripsList extends StatelessWidget {
  TripsList({
    Key? key,
    required this.tripsService,
    required this.userId,
  }) : super(key: key);

  final TripsService tripsService;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowingTripsCubit, FollowingTripsState>(
      buildWhen: (previous, current) =>
          previous.likesStatus != current.likesStatus ||
          previous.favoritesStatus != current.favoritesStatus ||
          previous.followStatus != current.followStatus,
      builder: (ctx, state) {
        return _TripList(
          userId: userId,
          stream: tripsService.getFollowingTrips(userId),
        );
      },
    );
  }
}

class _TripList extends StatelessWidget {
  _TripList({
    Key? key,
    required this.userId,
    required this.stream,
  }) : super(key: key);

  final String userId;
  final Stream<List<Trip>> stream;

  @override
  Widget build(BuildContext context) {
    final likesStatus =
        context.select((FollowingTripsCubit bloc) => bloc.state.likesStatus);
    final favoritesStatus = context
        .select((FollowingTripsCubit bloc) => bloc.state.favoritesStatus);
    final authUser = context.select((AuthBloc bloc) => bloc.state.authUser);

    return Container(
      child: StreamBuilder<List<Trip>>(
        stream: stream,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(child: Text(snapshot.error.toString())),
            );
          }

          if (snapshot.data == null) {
            return TripsLoader();
          }

          if (snapshot.data != null && snapshot.data!.length == 0) {
            return Center(child: Text('No data'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) {
              final trip = snapshot.data![index];

              return TripCard(
                id: trip.id,
                userName: trip.user.displayName,
                userPic: trip.user.photoUrl ?? '',
                publicationDate: trip.publicationDate,
                title: trip.title,
                description: trip.description,
                likesCount: trip.likesCount,
                isLiked: trip.isLiked,
                isLikesCountUpdating:
                    likesStatus == UserLikesStatus.loadInProgress,
                cost: trip.cost,
                imageUrl: trip.imageUrl,
                isFavorite: trip.isFavorite,
                ownerMenu: authUser.id == trip.user.userId
                    ? Container(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: const Icon(
                            CupertinoIcons.ellipsis,
                            color: CupertinoColors.systemGrey,
                          ),
                          onPressed: () {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                actions: <CupertinoActionSheetAction>[
                                  CupertinoActionSheetAction(
                                    child: const Text('Edit trip'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          TripEditorPage.route(trip: trip));
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text(
                                      'Delete trip',
                                      style: TextStyle(
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ),
                                    onPressed: () {
                                      ctx
                                          .read<FollowingTripsCubit>()
                                          .deleteTrip(trip.id);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
                isFavoriteUpdating:
                    favoritesStatus == UserFavoritesStatus.loadInProgress,
                onLikePress: () {
                  if (trip.isLiked) {
                    context
                        .read<FollowingTripsCubit>()
                        .dislikeTrip(trip.id, userId)
                        .then((_) => print('Dislike'));
                  } else {
                    context
                        .read<FollowingTripsCubit>()
                        .likeTrip(trip.id, userId)
                        .then((_) => print('Like'));
                  }
                },
                onFavoritePress: () {
                  if (trip.isFavorite) {
                    context
                        .read<FollowingTripsCubit>()
                        .deleteFavoriteTrip(trip.id, userId)
                        .then((_) => print('Delete favorite'));
                  } else {
                    context
                        .read<FollowingTripsCubit>()
                        .addFavoriteTrip(trip.id, userId)
                        .then((_) => print('Add favorite'));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
