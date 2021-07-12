import 'package:flutter/cupertino.dart';
import 'package:trips/widgets/widgets.dart';

class TripCard extends StatelessWidget {
  final String userName;
  final String userPic;
  final DateTime publicationDate;
  final String title;
  final String description;
  final int likesCount;
  final double cost;
  final String imageUrl;
  final bool isFavorite;

  const TripCard({
    required this.userName,
    required this.userPic,
    required this.publicationDate,
    required this.title,
    required this.description,
    required this.likesCount,
    required this.cost,
    required this.imageUrl,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: CupertinoTheme.of(context)
                  .textTheme
                  .tabLabelTextStyle
                  .color!
                  .withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          _TripCardHeader(
            userName: userName,
            userPic: userPic,
            publicationDate: publicationDate,
          ),
          const SizedBox(height: 5),
          _TripCardBody(
            title: title,
            description: description,
            imageUrl: imageUrl,
          ),
          _TripCardPanel(
            likesCount: likesCount,
            cost: cost,
            isFavorite: isFavorite,
          ),
        ],
      ),
    );
  }
}

/// Build avatar, user name and date / time
class _TripCardHeader extends StatelessWidget {
  _TripCardHeader({
    required this.userName,
    required this.userPic,
    required this.publicationDate,
  });

  final String userName;
  final String userPic;
  final DateTime publicationDate;

  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              EventDateTime(publicationDate),
            ],
          ),
          Row(
            children: [
              UserPic(
                url: userPic,
                size: 50,
              ),
              const SizedBox(width: 5),
              Text(
                userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Build a title, description and image
class _TripCardBody extends StatelessWidget {
  const _TripCardBody({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTitle(title),
                const SizedBox(height: 10),
                Text(description),
              ],
            ),
          ),
          const SizedBox(height: 5),
          _buildTripImage(context)
        ],
      ),
    );
  }

  Widget _buildTripImage(BuildContext context) {
    return Image.network(
      imageUrl,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Center(
          child: CupertinoActivityIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        child: Text(
          'Loading image error',
        ),
        margin: const EdgeInsets.only(top: 100),
      ),
    );
  }
}

/// Build likes count, a trip cost and a favorite button
class _TripCardPanel extends StatelessWidget {
  _TripCardPanel({
    required this.likesCount,
    required this.cost,
    required this.isFavorite,
  });

  final int likesCount;
  final double cost;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLikesCount(context),
            const SizedBox(width: 15),
            _buildTripCost(context),
          ],
        ),
        CupertinoButton(
            child: isFavorite
                ? Icon(CupertinoIcons.bookmark_fill)
                : Icon(CupertinoIcons.bookmark),
            onPressed: () {})
      ],
    );
  }

  Widget _buildLikesCount(BuildContext context) {
    return Row(
      children: [
        likesCount > 0
            ? Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
              )
            : Icon(
                CupertinoIcons.heart,
                color: CupertinoColors.systemRed,
              ),
        const SizedBox(width: 5),
        Text(likesCount.toString()),
      ],
    );
  }

  Widget _buildTripCost(BuildContext context) {
    if (cost > 0) {
      return Row(
        children: [
          Icon(CupertinoIcons.money_dollar_circle),
          const SizedBox(width: 5),
          Text(cost.toStringAsFixed(2)),
        ],
      );
    }
    return Container();
  }
}
