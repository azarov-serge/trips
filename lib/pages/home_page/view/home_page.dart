import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/drafts_trips_page/view/drafts_trips_page.dart';
import 'package:trips/pages/pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page page() => const CupertinoPage<void>(child: HomePage());

  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_app),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        final authUser = context.select((AuthBloc bloc) => bloc.state.authUser);

        switch (index) {
          case 0:
            return FollowingTripsPage(userId: authUser.id);
          case 1:
            return SearchPage();
          case 2:
            return DraftsTripsPage();
          case 3:
            return ProfilePage(userId: authUser.id);
          default:
            return FollowingTripsPage(userId: authUser.id);
        }
      },
    );
  }
}
