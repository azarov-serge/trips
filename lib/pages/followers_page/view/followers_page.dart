import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class FollowersPage extends StatelessWidget {
  FollowersPage({
    Key? key,
    required this.usersService,
    required this.userId,
    required this.usersIds,
    required this.title,
    this.isFollowers = false,
    this.isAuthUser = false,
  }) : super(key: key);

  static Page page({
    required UsersService usersService,
    required String userId,
    required List<String> usersIds,
    required String title,
    bool? isFollowers,
    bool? isAuthUser,
  }) =>
      CupertinoPage<void>(
        child: FollowersPage(
          usersService: usersService,
          userId: userId,
          usersIds: usersIds,
          title: title,
          isFollowers: isFollowers,
          isAuthUser: isAuthUser,
        ),
      );

  static Route route({
    required UsersService usersService,
    required String userId,
    required List<String> usersIds,
    required String title,
    bool? isFollowers,
    bool? isAuthUser,
  }) {
    return CupertinoPageRoute<void>(
      builder: (_) => FollowersPage(
        usersService: usersService,
        userId: userId,
        usersIds: usersIds,
        title: title,
        isFollowers: isFollowers,
        isAuthUser: isAuthUser,
      ),
    );
  }

  final UsersService usersService;
  final String userId;
  final List<String> usersIds;
  final String title;
  final bool? isFollowers;
  final bool? isAuthUser;

  @override
  Widget build(BuildContext context) {
    final Stream<List<User>> stream = isFollowers == true
        ? usersService.getFollowers(userId)
        : usersService.getFollowing(userId);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: StreamBuilder<List<User>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: const TripsLoader());
          }

          if (snapshot.data?.length == 0) {
            return Center(child: const Text('Users not found'));
          }

          return Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                final user = snapshot.data![index];

                final followerWidget = _Follower(
                  user: user,
                  onViewProfile: () => Navigator.of(context)
                      .push(ProfilePage.route(userId: user.userId)),
                );

                return isAuthUser == true
                    ? Dismissible(
                        key: Key(user.userId),
                        direction: DismissDirection.endToStart,
                        child: Container(
                          child: followerWidget,
                        ),
                        background: Container(
                          color: CupertinoColors.systemRed,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                CupertinoIcons.trash,
                                color: CupertinoColors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Remove',
                                style: TextStyle(color: CupertinoColors.white),
                              )
                            ],
                          ),
                        ),
                        // movementDuration: const Duration(milliseconds: 500),
                        confirmDismiss: (direction) {
                          return showCupertinoDialog(
                            context: context,
                            builder: (ctx) => CupertinoAlertDialog(
                              content: Text('Do yoy wan\'t remove user?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    await _removeUser(user.userId);
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : followerWidget;
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeUser(String removedUserId) async {
    if (isFollowers == true && isAuthUser == true) {
      await usersService.removeFollower(userId);
    } else {
      await usersService.removeFollowing(userId);
    }
  }
}

class _Follower extends StatelessWidget {
  _Follower({
    Key? key,
    required this.user,
    required this.onViewProfile,
  }) : super(key: key);

  final User user;
  final Function onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: CupertinoListTile(
        leading: UserPic(url: user.photoUrl ?? ''),
        title: user.displayName,
        subtitle: user.email,
        trailing: CupertinoButton(
          padding: EdgeInsets.all(5),
          child: Text('View profile'),
          onPressed: () => onViewProfile(),
        ),
      ),
    );
  }
}
