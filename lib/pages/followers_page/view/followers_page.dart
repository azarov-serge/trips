import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class FollowersPage extends StatefulWidget {
  FollowersPage({
    Key? key,
    required this.usersService,
    required this.usersIds,
    required this.title,
    this.isFollowers = false,
    this.isAuthUser = false,
  }) : super(key: key);

  static Page page({
    required UsersService usersService,
    required List<String> usersIds,
    required String title,
    bool? isFollowers,
    bool? isAuthUser,
  }) =>
      CupertinoPage<void>(
        child: FollowersPage(
          usersService: usersService,
          usersIds: usersIds,
          title: title,
          isFollowers: isFollowers,
          isAuthUser: isAuthUser,
        ),
      );

  static Route route({
    required UsersService usersService,
    required List<String> usersIds,
    required String title,
    bool? isFollowers,
    bool? isAuthUser,
  }) {
    return CupertinoPageRoute<void>(
      builder: (_) => FollowersPage(
        usersService: usersService,
        usersIds: usersIds,
        title: title,
        isFollowers: isFollowers,
        isAuthUser: isAuthUser,
      ),
    );
  }

  final UsersService usersService;
  final List<String> usersIds;
  final String title;
  final bool? isFollowers;
  final bool? isAuthUser;

  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<String> _usersIds = [];

  @override
  void initState() {
    _usersIds = widget.usersIds;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> stream =
        widget.usersService.getUsersListByIds(_usersIds);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: const TripsLoader());
          }

          if (snapshot.data?.docs.length == 0) {
            return Center(child: const Text('Users not found'));
          }

          final usersData = snapshot.data!.docs;

          return Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: ListView.builder(
              itemCount: usersData.length,
              itemBuilder: (ctx, index) {
                final user = User(
                  userId: usersData[index]['userId'],
                  email: usersData[index]['email'],
                  displayName: usersData[index]['displayName'],
                );

                final followerWidget = _Follower(
                  user: user,
                  onViewProfile: () => Navigator.of(context)
                      .push(ProfilePage.route(userId: user.userId)),
                );

                return widget.isAuthUser == true
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
                        movementDuration: const Duration(milliseconds: 500),
                        confirmDismiss: (direction) {
                          return showCupertinoDialog(
                            context: context,
                            builder: (ctx) => CupertinoAlertDialog(
                              content: Text('Do yoy wan\'t remove user?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    _removeUser(user.userId);
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

  void _removeUser(String removedUserId) {
    Function onRemove;

    if (widget.isFollowers == true && widget.isAuthUser == true) {
      onRemove = (String userId) => widget.usersService.removeFollower(userId);
    } else {
      onRemove = (String userId) => widget.usersService.removeFollowing(userId);
    }

    onRemove(removedUserId).then((_) {
      setState(() {
        _usersIds =
            _usersIds.where((element) => element != removedUserId).toList();
      });
    });
  }

  Future _showErrorAlert(BuildContext context, String errorMessage) {
    return showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: [
          CupertinoDialogAction(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Follower extends StatelessWidget {
  _Follower({
    Key? key,
    required this.user,
    required this.onViewProfile,
  }) : super(key: key);

  User user;
  Function onViewProfile;

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
