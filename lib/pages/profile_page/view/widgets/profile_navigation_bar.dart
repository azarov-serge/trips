import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/services/services.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/pages.dart';

class ProfileNavigationBar extends StatelessWidget {
  ProfileNavigationBar({
    Key? key,
    required this.user,
    required this.isAuthUser,
  }) : super(key: key);

  final User user;
  final bool isAuthUser;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverNavigationBar(
      leading: isAuthUser ? null : const _BackButton(),
      trailing: isAuthUser ? _ProfileMenu(user: user) : null,
      largeTitle: Text(user.displayName),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(10),
      child: Icon(CupertinoIcons.back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  _ProfileMenu({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(10),
      child: Icon(CupertinoIcons.settings),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                child: const Text('Edit profile'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(EditProfilePage.route(user: user));
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('Log out'),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthEventLogoutRequested());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
