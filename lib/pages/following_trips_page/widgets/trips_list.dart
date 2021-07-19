import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class TripsList extends StatelessWidget {
  TripsList({
    Key? key,
    required this.tripsServices,
    required this.userId,
  }) : super(key: key);

  final TripsService tripsServices;
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
          stream: tripsServices.getFollowingTrips(userId),
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
  late Stream<List<Trip>> stream;

  @override
  Widget build(BuildContext context) {
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
                cost: trip.cost,
                imageUrl: trip.imageUrl,
                isFavorite: trip.isFavorite,
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
