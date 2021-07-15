import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'widgets/widgets.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({Key? key, required this.user}) : super(key: key);
  static Page page({required User user}) =>
      CupertinoPage<void>(child: EditProfilePage(user: user));

  static Route route({required User user}) {
    return CupertinoPageRoute<void>(
        builder: (_) => EditProfilePage(user: user));
  }

  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit profile'),
      ),
      child: BlocProvider<EditProfileCubit>(
        create: (_) => EditProfileCubit(UsersService()),
        child: EditProfileForm(user: user),
      ),
    );
  }
}
