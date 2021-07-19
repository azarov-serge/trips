import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/following_trips_page/widgets/widgets.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class FollowingTripsPage extends StatelessWidget {
  FollowingTripsPage({Key? key, required this.userId}) : super(key: key);

  static Page page({required String userId}) =>
      CupertinoPage<void>(child: FollowingTripsPage(userId: userId));

  static Route route({required String userId}) {
    return CupertinoPageRoute<void>(
        builder: (_) => FollowingTripsPage(userId: userId));
  }

  final String userId;
  final UsersService _usersService = UsersService();
  final TripsService _tripsServices = TripsService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Container(padding: EdgeInsets.all(5), child: Logo()),
      ),
      child: BlocProvider(
        create: (_) => FollowingTripsCubit(
          usersService: _usersService,
          authService: context.read<AuthService>(),
          tripsServices: _tripsServices,
        ),
        child: Center(
          child: TripsList(tripsServices: _tripsServices, userId: userId),
        ),
      ),
    );
  }
}
