import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'widgets/widgets.dart';

class TripEditorPage extends StatelessWidget {
  static Page page({Trip? trip}) =>
      CupertinoPage<void>(child: TripEditorPage(trip: trip));

  static Route route({Trip? trip}) {
    return CupertinoPageRoute<void>(builder: (_) => TripEditorPage(trip: trip));
  }

  TripEditorPage({this.trip});

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final isEditMode = trip != null;

    return BlocProvider<TripEditorCubit>(
      create: (_) => TripEditorCubit(TripsService()),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(
            padding: EdgeInsets.all(10),
            child: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: isEditMode ? Text('Edit a trip') : Text('Add a trip'),
          trailing: isEditMode
              ? BlocBuilder<TripEditorCubit, TripEditorState>(
                  buildWhen: (previous, current) =>
                      previous.description != current.description,
                  builder: (context, state) {
                    return CupertinoButton(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: CupertinoColors.destructiveRed),
                      ),
                      onPressed: () async {
                        await context
                            .read<TripEditorCubit>()
                            .deleteTrip(trip!.id);
                        Navigator.of(context).pop();
                      },
                    );
                  })
              : null,
        ),
        child: TripEditorForm(trip: trip),
      ),
    );
  }
}
