import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/services/services.dart';
import 'package:trips/widgets/widgets.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(),
        _SearchBody(),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  late UsersSearchBloc _usersSearchBloc;

  @override
  void initState() {
    super.initState();
    _usersSearchBloc = context.read<UsersSearchBloc>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: CupertinoSearchTextField(
        controller: _textController,
        placeholder: 'Enter a user\'s display name',
        onChanged: (text) {
          _usersSearchBloc.add(
            UsersSearchEventTextChanged(text: text),
          );
        },
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersSearchBloc, UsersSearchState>(
      builder: (context, state) {
        if (state is UsersSearchStateLoading) {
          return const CupertinoActivityIndicator();
        }

        if (state is UsersSearchStateError) {
          return Text(state.error);
        }

        if (state is UsersSearchStateSuccess) {
          return state.items.length == 0
              ? const Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
        return const Text('Please enter a term to begin');
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({Key? key, required this.items}) : super(key: key);

  final List<User> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return CupertinoListTile(
          leading: UserPic(
            url: items[index].photoUrl ?? '',
          ),
          title: items[index].displayName,
          subtitle: items[index].email,
          trailing: CupertinoButton(
              child: Text('View profile'),
              onPressed: () {
                Navigator.of(context)
                    .push(ProfilePage.route(userId: items[index].userId));
              }),
        );
      },
    );
  }
}
