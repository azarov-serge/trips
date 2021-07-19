import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class DraftsTripsPage extends StatelessWidget {
  static Page page({required String userId}) =>
      CupertinoPage<void>(child: DraftsTripsPage());

  static Route route({required String userId}) {
    return CupertinoPageRoute<void>(builder: (_) => DraftsTripsPage());
  }

  final TripsService _tripsServices = TripsService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Drafts'),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 100),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: const _CreateTripButton()),
            SliverToBoxAdapter(
              child: _DraftsTripts(tripsServices: _tripsServices),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTripButton extends StatelessWidget {
  const _CreateTripButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.add_circled_solid),
          SizedBox(width: 5),
          Text('Create trip'),
        ],
      ),
      onPressed: () {
        Navigator.of(context).push(TripEditorPage.route());
      },
    );
  }
}

class _DraftsTripts extends StatelessWidget {
  _DraftsTripts({Key? key, required this.tripsServices}) : super(key: key);

  final TripsService tripsServices;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
      stream: tripsServices.getUserTripsDrafts(),
      builder: (BuildContext ctx, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CupertinoActivityIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.length == 0) {
          return Center(child: Text('No drafts of trips'));
        }

        return Column(
          children: snapshot.data!.map((trip) {
            final updatedDate =
                DateFormat('dd.MM.yyyy').format(trip.publicationDate) +
                    ' ' +
                    DateFormat('Hm').format(trip.publicationDate);

            return CupertinoListTile(
                leading: Container(),
                title: trip.title,
                subtitle: updatedDate,
                trailing: _buildEditButton(context, trip));
          }).toList(),
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context, Trip trip) {
    return CupertinoButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.pencil),
          SizedBox(width: 5),
          Text('Edit'),
        ],
      ),
      onPressed: () {
        Navigator.of(context).push(TripEditorPage.route(trip: trip));
      },
    );
  }
}
