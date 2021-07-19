import 'package:trips/services/services.dart';

class Trip {
  Trip({
    required this.id,
    required this.publicationDate,
    required this.isPublic,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.likesCount,
    required this.cost,
    required this.isLiked,
    required this.isFavorite,
    required this.user,
  });

  final String id;
  final DateTime publicationDate;
  final bool isPublic;
  final String title;
  final String description;
  final String imageUrl;
  final int likesCount;
  final double cost;
  final bool isLiked;
  final bool isFavorite;
  final User user;
}
