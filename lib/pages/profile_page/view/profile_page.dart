import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';
import 'widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key, required this.userId}) : super(key: key);

  static Page page({required String userId}) =>
      CupertinoPage<void>(child: ProfilePage(userId: userId));

  static Route route({required String userId}) {
    return CupertinoPageRoute<void>(
        builder: (_) => ProfilePage(userId: userId));
  }

  final String userId;
  final UsersService _usersService = UsersService();
  final TripsService _tripsService = TripsService();

  @override
  Widget build(BuildContext context) {
    final authUser = context.select((AuthBloc bloc) => bloc.state.authUser);
    return StreamBuilder<QuerySnapshot>(
      stream: _usersService.getUserByUserId(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: const TripsLoader());
        }

        if (snapshot.data?.docs.length == 0) {
          return Center(child: const Text('User not found'));
        }

        final userData = snapshot.data!.docs.first;
        final User user = User(
          userId: userData['userId'],
          email: userData['email'],
          displayName: userData['displayName'],
          photoUrl: userData['photoUrl'],
          description: userData['description'],
        );

        return BlocProvider(
          create: (_) => ProfileCubit(
            usersService: _usersService,
            authService: context.read<AuthService>(),
            tripsService: _tripsService,
          ),
          child: _buildContent(context, user, authUser),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, User user, AuthUser authUser) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          ProfileNavigationBar(
            user: user,
            isAuthUser: authUser.id == user.userId,
          ),
          SliverToBoxAdapter(
            child: Profile(usersService: _usersService, user: user),
          ),
          SliverToBoxAdapter(
            child: TripsLists(tripsServices: _tripsService, user: user),
          ),
        ],
      ),
    );
  }
}
