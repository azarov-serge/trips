import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/services/services.dart';
import 'widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: LoginPage());

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: BlocProvider(
          create: (_) => LoginCubit(context.read<AuthenticationService>()),
          child: LoginForm(),
        ),
      ),
    );
  }
}
