import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';
import 'widgets/widgets.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Search'),
      ),
      child: BlocProvider(
        create: (_) => UsersSearchBloc(usersService: UsersService()),
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 100, 10, 10),
          child: SearchForm(),
        ),
      ),
    );
  }
}
