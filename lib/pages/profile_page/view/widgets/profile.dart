import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class Profile extends StatelessWidget {
  Profile({
    Key? key,
    required this.usersService,
    required this.user,
  }) : super(key: key);

  final UsersService usersService;
  final User user;

  @override
  Widget build(BuildContext context) {
    final authUser = context.select((AuthBloc bloc) => bloc.state.authUser);
    final isAuthUser = authUser.id == user.userId;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.followStatus == FollowStatus.error) {
          _showErrorAlert(context, 'Authentication Failure');
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserPic(
                      url: user.photoUrl ?? '',
                      size: MediaQuery.of(context).size.width * 0.35,
                    ),
                    Column(
                      children: [
                        _UserStats(
                          usersService: usersService,
                          userId: user.userId,
                          isAuthUser: isAuthUser,
                        ),
                        isAuthUser
                            ? Container()
                            : _FollowButton(
                                userId: user.userId,
                                followerId: authUser.id,
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            _UserInfo(
              displayName: user.displayName,
              email: user.email,
              description: user.description ?? '',
            ),
          ],
        ),
      ),
    );
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

class _FollowButton extends StatefulWidget {
  const _FollowButton({
    Key? key,
    required this.userId,
    required this.followerId,
  }) : super(key: key);

  final String userId;
  final String followerId;

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  @override
  void initState() {
    context.read<ProfileCubit>().getFollowers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.followStatus != current.followStatus,
      builder: (ctx, state) {
        final followingIds = state.followingIds;

        final isNotFollowing = followingIds.length > 0
            ? followingIds.where((id) => id == widget.userId).toList().length ==
                0
            : true;
        print(followingIds);
        return Container(
          margin: EdgeInsets.only(top: 10),
          height: 45,
          width: MediaQuery.of(context).size.width * 0.5,
          child: state.followStatus != FollowStatus.done
              ? CupertinoActivityIndicator()
              : Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 30,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    padding: EdgeInsets.all(0),
                    child: Text(
                      isNotFollowing == true ? 'Follow' : 'Unfollow',
                      style:
                          TextStyle(color: CupertinoColors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      if (isNotFollowing) {
                        context.read<ProfileCubit>().follow(widget.userId);
                      } else {
                        context.read<ProfileCubit>().unfollow(widget.userId);
                      }
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _UserStatsElement extends StatelessWidget {
  _UserStatsElement({required this.title, required this.value});

  final String title;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          value,
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _UserStats extends StatelessWidget {
  _UserStats({
    required this.usersService,
    required this.userId,
    required this.isAuthUser,
  });

  final UsersService usersService;
  final String userId;
  final bool isAuthUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _UserTripsCount(
            usersService: usersService,
            userId: userId,
          ),
          _UserFollowersCount(
            usersService: usersService,
            userId: userId,
            isAuthUser: isAuthUser,
          ),
          _UserFollowingCount(
            usersService: usersService,
            userId: userId,
            isAuthUser: isAuthUser,
          ),
        ],
      ),
    );
  }
}

class _UserTripsCount extends StatelessWidget {
  _UserTripsCount({required this.usersService, required this.userId});

  final UsersService usersService;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: usersService.getTripsIdsByUserId(userId),
      builder: (context, snapshot) {
        String tripsCount = '';
        if (!snapshot.hasData) {
          tripsCount = '-';
        } else {
          tripsCount =
              snapshot.data != null ? snapshot.data!.length.toString() : '-';
        }

        final tripssWidget = CupertinoButton(
            child: Text(
              tripsCount,
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color),
            ),
            onPressed: () {});

        return _UserStatsElement(title: 'trips', value: tripssWidget);
      },
    );
  }
}

class _UserFollowersCount extends StatelessWidget {
  _UserFollowersCount({
    required this.usersService,
    required this.userId,
    required this.isAuthUser,
  });

  final UsersService usersService;
  final String userId;
  final bool isAuthUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: usersService.getFollowersIdsByUserId(userId),
      builder: (ctx, snapshot) {
        String followersCount;

        if (!snapshot.hasData) {
          followersCount = '0';
        } else if (snapshot.data!.length == 0) {
          followersCount = '0';
        } else {
          followersCount = snapshot.data!.length.toString();
        }

        final isNeedCallback = followersCount != '-' && followersCount != '0';

        final followersWidget = CupertinoButton(
            child: Text(followersCount),
            onPressed: isNeedCallback
                ? () {
                    Navigator.of(context).push(
                      FollowersPage.route(
                        usersService: usersService,
                        userId: userId,
                        title: 'Followers',
                        isFollowers: true,
                        isAuthUser: isAuthUser,
                      ),
                    );
                  }
                : () {});

        return _UserStatsElement(title: 'followers', value: followersWidget);
      },
    );
  }
}

class _UserFollowingCount extends StatelessWidget {
  _UserFollowingCount({
    required this.usersService,
    required this.userId,
    required this.isAuthUser,
  });

  final UsersService usersService;
  final String userId;
  final bool isAuthUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: usersService.getFollowingIdsByUserId(userId),
      builder: (context, snapshot) {
        String followingCount;

        if (!snapshot.hasData) {
          followingCount = '0';
        } else if (snapshot.data!.length == 0) {
          followingCount = '0';
        } else {
          followingCount = snapshot.data!.length.toString();
        }

        final isNeedCallback = followingCount != '-' && followingCount != '0';

        final follwingWidget = CupertinoButton(
            child: Text(followingCount),
            onPressed: isNeedCallback
                ? () {
                    Navigator.of(context).push(
                      FollowersPage.route(
                        usersService: usersService,
                        userId: userId,
                        title: 'Following',
                        isAuthUser: isAuthUser,
                      ),
                    );
                  }
                : () {});

        return _UserStatsElement(title: 'following', value: follwingWidget);
      },
    );
  }
}

class _UserInfo extends StatelessWidget {
  _UserInfo({
    Key? key,
    required this.displayName,
    required this.email,
    required this.description,
  }) : super(key: key);

  final String displayName;
  final String email;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(CupertinoIcons.envelope),
              SizedBox(width: 5),
              Text(email),
            ],
          ),
          SizedBox(height: 10),
          Text(description),
        ],
      ),
    );
  }
}
