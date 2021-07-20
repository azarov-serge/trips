import 'package:trips/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Trip.fromDoc({
    required QueryDocumentSnapshot doc,
    required bool isLiked,
    required bool isFavorite,
    required User user,
  }) {
    return Trip(
      id: doc.id,
      publicationDate: DateTime.fromMillisecondsSinceEpoch(
          doc['publicationDate'].seconds * 1000),
      isPublic: doc['isPublic'],
      title: doc['title'],
      description: doc['description'],
      imageUrl: doc['imageUrl'],
      likesCount: int.parse(doc['likesCount'].toString()),
      cost: double.parse(doc['cost'].toString()),
      isLiked: isLiked,
      isFavorite: isFavorite,
      user: user,
    );
  }
}
