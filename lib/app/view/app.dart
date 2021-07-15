import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:trips/services/services.dart';
import 'package:trips/app/app.dart';
import 'package:trips/blocs/blocs.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authService,
    required this.usersService,
  }) : super(key: key);

  final AuthService authService;
  final UsersService usersService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authService,
      child: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          authService: authService,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: FlowBuilder<AuthStatus>(
        state: context.select((AuthBloc bloc) => bloc.state.status),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
