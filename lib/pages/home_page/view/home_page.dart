import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

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
        switch (index) {
          case 0:
            return _buildSplashPage(context, 'Home');
          case 1:
            return SearchPage();
          case 2:
            return _buildSplashPage(context, 'Add trip');
          case 3:
            final authUser =
                context.select((AuthBloc bloc) => bloc.state.authUser);

            return ProfilePage(userId: authUser.id);
          default:
            return _buildSplashPage(context, 'Home');
        }
      },
    );
  }

  // TODO: Remove
  Widget _buildSplashPage(BuildContext context, String pageName) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(pageName),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(5),
          child: Text('Log out'),
          onPressed: () {
            context.read<AuthBloc>().add(AuthEventLogoutRequested());
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 200, child: TripsLoader()),
        ],
      ),
    );
  }
}
