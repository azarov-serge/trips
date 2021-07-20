import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/services/services.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class TripsLists extends StatefulWidget {
  TripsLists({
    Key? key,
    required this.tripsServices,
    required this.user,
  }) : super(key: key);

  final TripsService tripsServices;
  final User user;

  @override
  _TripsListsState createState() => _TripsListsState();
}

class _TripsListsState extends State<TripsLists> {
  late int _activeTripsListsType = 0;
  late Stream<List<Trip>> _activeTripsListsStream =
      widget.tripsServices.getUserTrips(widget.user.userId);

  void _toggleTripsListsType(value) {
    setState(() {
      _activeTripsListsType = value;
      if (value == 0) {
        _activeTripsListsStream =
            widget.tripsServices.getUserTrips(widget.user.userId);
      } else {
        _activeTripsListsStream =
            widget.tripsServices.getUserFavoritesTrips(widget.user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: CupertinoSegmentedControl(
            groupValue: _activeTripsListsType,
            children: {
              0: Icon(CupertinoIcons.person_crop_square),
              1: Icon(CupertinoIcons.bookmark_fill),
            },
            onValueChanged: _toggleTripsListsType,
          ),
        ),
        BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (previous, current) =>
              previous.likesStatus != current.likesStatus ||
              previous.favoritesStatus != current.favoritesStatus,
          builder: (ctx, state) {
            return _TripList(
              user: widget.user,
              stream: _activeTripsListsStream,
              isFavoritesList: _activeTripsListsType == 1,
            );
          },
        ),
      ],
    );
  }
}

class _TripList extends StatelessWidget {
  _TripList({
    Key? key,
    required this.user,
    required this.stream,
    required this.isFavoritesList,
  }) : super(key: key);

  final User user;
  final Stream<List<Trip>> stream;
  final bool isFavoritesList;

  @override
  Widget build(BuildContext context) {
    final authUser = context.select((AuthBloc bloc) => bloc.state.authUser);

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 100),
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

          final tripCars = snapshot.data!.map((trip) {
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
                                    Navigator.of(context)
                                        .push(TripEditorPage.route(trip: trip));
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
                                        .read<ProfileCubit>()
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
              onLikePress: () {
                if (trip.isLiked) {
                  context
                      .read<ProfileCubit>()
                      .dislikeTrip(trip.id, authUser.id)
                      .then((_) => print('Dislike'));
                } else {
                  context
                      .read<ProfileCubit>()
                      .likeTrip(trip.id, authUser.id)
                      .then((_) => print('Like'));
                }
              },
              onFavoritePress: () {
                if (trip.isFavorite) {
                  context
                      .read<ProfileCubit>()
                      .deleteFavoriteTrip(trip.id, authUser.id)
                      .then((_) => print('Delete favorite'));
                } else {
                  context
                      .read<ProfileCubit>()
                      .addFavoriteTrip(trip.id, authUser.id)
                      .then((_) => print('Add favorite'));
                }
              },
            );
          }).toList();

          return Column(
            children: <Widget>[
              ...tripCars,
            ],
          );
        },
      ),
    );
  }
}
