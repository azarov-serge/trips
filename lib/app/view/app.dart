import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:trips/services/services.dart';
import 'package:trips/app/app.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationService authenticationService,
  })  : _authenticationService = authenticationService,
        super(key: key);

  final AuthenticationService _authenticationService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationService,
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationService: _authenticationService,
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
      home: FlowBuilder<AppStatus>(
        state: context.select((AppBloc bloc) => bloc.state.status),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
