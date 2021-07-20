import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as _firebaseAuth_;
import 'package:cache/cache.dart';
import 'package:trips/services/services.dart';
import 'package:trips/services/trips_service/models/trip.dart';

User parseUser(doc) {
  return User(
    userId: doc['userId'],
    email: doc['email'],
    displayName: doc['displayName'],
    photoUrl: doc['photoUrl'],
    description: doc['description'],
  );
}

/// Service which manages trips.
class TripsService {
  TripsService();

  final FirebaseFirestore _firebaseFirestore = firebaseFirestore;
  final _firebaseAuth_.FirebaseAuth _firebaseAuth = firebaseAuth;
  final FirebaseStorage _firebaseStorage = firebaseStorage;
  final CacheClient _cache = CacheClient();

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  CollectionReference get _usersCollection =>
      _firebaseFirestore.collection('users');

  CollectionReference get _tripsCollection =>
      _firebaseFirestore.collection('trips');

  CollectionReference get _favoritesCollection =>
      _firebaseFirestore.collection('favorites');

  CollectionReference get _followersCollection =>
      _firebaseFirestore.collection('followers');

  CollectionReference get _likesCollection =>
      _firebaseFirestore.collection('likes');

  Stream<AuthUser> get authUser {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user =
          firebaseUser == null ? AuthUser.empty : firebaseUser.toAuthUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  Future<List<String>> getFollowingIds(String userId) async {
    try {
      final List<String> ids = [];
      final data = await _followersCollection
          .where('followerId', isEqualTo: userId)
          .get();

      data.docs.forEach((doc) {
        ids.add(doc['userId']);
      });

      return ids;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<String>> getLikesIds() async {
    try {
      final user = await authUser.first;
      final List<String> ids = [];
      final data =
          await _likesCollection.where('userId', isEqualTo: user.id).get();

      data.docs.forEach((doc) {
        ids.add(doc['tripId']);
      });

      return ids;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<String>> getFavoritesIds(String userId) async {
    try {
      final List<String> ids = [];
      final data =
          await _favoritesCollection.where('userId', isEqualTo: userId).get();

      data.docs.forEach((doc) {
        ids.add(doc['tripId']);
      });

      return ids;
    } catch (error) {
      throw Exception(error);
    }
  }

  bool isLikedTrip(List<String> likeIds, String tripId) {
    return likeIds.length == 0
        ? false
        : likeIds.where((likeId) => likeId == tripId).length > 0;
  }

  bool isFavoriteTrip(List<String> favoriteIds, String tripId) {
    return favoriteIds.length == 0
        ? false
        : favoriteIds.where((favoriteId) => favoriteId == tripId).length > 0;
  }

  Future<User> getUser(String userId) async {
    final userData =
        await _usersCollection.where('userId', isEqualTo: userId).get();

    final doc = userData.docs[0];
    return compute(parseUser, doc);
    // return parseUser(doc);
  }

  Stream<List<Trip>> getFollowingTrips(String userId) async* {
    try {
      final user = await authUser.first;
      final followingIds = await getFollowingIds(userId);
      final snapshots = _tripsCollection
          .where('userId', whereIn: [userId, ...followingIds])
          .where('isPublic', isEqualTo: true)
          .snapshots();

      await for (final snapshot in snapshots) {
        final List<Trip> trips = [];
        final List<String> likeIds = await getLikesIds();
        final List<String> favoriteIds = await getFavoritesIds(user.id);

        for (int index = 0; index < snapshot.docs.length; index++) {
          final trip = snapshot.docs[index];

          final user = await getUser(trip['userId']);

          final isLiked = isLikedTrip(likeIds, trip.id);
          final isFavorite = isFavoriteTrip(favoriteIds, trip.id);

          trips.add(Trip.fromDoc(
              doc: trip, isLiked: isLiked, isFavorite: isFavorite, user: user));
        }

        yield trips;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Stream<List<Trip>> getUserTrips(String userId) async* {
    try {
      final user = await authUser.first;
      final snapshots = _tripsCollection
          .where('userId', isEqualTo: userId)
          .where('isPublic', isEqualTo: true)
          .snapshots();

      await for (final snapshot in snapshots) {
        final List<User> users = [];
        final List<Trip> trips = [];
        final List<String> likeIds = await getLikesIds();
        final List<String> favoriteIds = await getFavoritesIds(user.id);

        for (int index = 0; index < snapshot.docs.length; index++) {
          final trip = snapshot.docs[index];
          final userData = await _usersCollection
              .where('userId', isEqualTo: trip['userId'])
              .get();

          final userDoc = userData.docs[0];

          final user = User(
            userId: userDoc['userId'],
            email: userDoc['email'],
            displayName: userDoc['displayName'],
            photoUrl: userDoc['photoUrl'],
            description: userDoc['description'],
          );

          users.add(user);

          final isLiked = isLikedTrip(likeIds, trip.id);

          final isFavorite = isFavoriteTrip(favoriteIds, trip.id);

          trips.add(Trip(
            id: trip.id,
            publicationDate: DateTime.fromMillisecondsSinceEpoch(
                trip['publicationDate'].seconds * 1000),
            isPublic: trip['isPublic'],
            title: trip['title'],
            description: trip['description'],
            imageUrl: trip['imageUrl'],
            likesCount: int.parse(trip['likesCount'].toString()),
            cost: double.parse(trip['cost'].toString()),
            isLiked: isLiked,
            isFavorite: isFavorite,
            user: user,
          ));
        }

        yield trips;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Stream<List<Trip>> getUserTripsDrafts() async* {
    try {
      final user = await authUser.first;
      final snapshots = _tripsCollection
          .where('userId', isEqualTo: user.id)
          .where('isPublic', isEqualTo: false)
          .snapshots();

      await for (final snapshot in snapshots) {
        final List<User> users = [];
        final List<Trip> trips = [];
        final List<String> likeIds = await getLikesIds();
        final List<String> favoriteIds = await getFavoritesIds(user.id);

        for (int index = 0; index < snapshot.docs.length; index++) {
          final trip = snapshot.docs[index];
          final userData = await _usersCollection
              .where('userId', isEqualTo: trip['userId'])
              .get();

          final userDoc = userData.docs[0];

          final user = User(
            userId: userDoc['userId'],
            email: userDoc['email'],
            displayName: userDoc['displayName'],
            photoUrl: userDoc['photoUrl'],
            description: userDoc['description'],
          );

          users.add(user);

          final isLiked = isLikedTrip(likeIds, trip.id);

          final isFavorite = isFavoriteTrip(favoriteIds, trip.id);

          trips.add(Trip(
            id: trip.id,
            publicationDate: DateTime.fromMillisecondsSinceEpoch(
                trip['publicationDate'].seconds * 1000),
            isPublic: trip['isPublic'],
            title: trip['title'],
            description: trip['description'],
            imageUrl: trip['imageUrl'],
            likesCount: int.parse(trip['likesCount'].toString()),
            cost: double.parse(trip['cost'].toString()),
            isLiked: isLiked,
            isFavorite: isFavorite,
            user: user,
          ));
        }

        yield trips;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Stream<List<Trip>> getUserFavoritesTrips(String userId) async* {
    try {
      final user = await authUser.first;
      final snapshots =
          _tripsCollection.where('isPublic', isEqualTo: true).snapshots();

      await for (final snapshot in snapshots) {
        final List<String> authFavoriteIds = await getFavoritesIds(user.id);
        final List<String> favoriteIds = await getFavoritesIds(userId);
        final List<String> likeIds = await getLikesIds();
        final List<Trip> trips = [];

        for (int index = 0; index < snapshot.docs.length; index++) {
          final trip = snapshot.docs[index];
          final isFavorite = isFavoriteTrip(favoriteIds, trip.id);

          final userData = await _usersCollection
              .where('userId', isEqualTo: trip['userId'])
              .get();

          final userDoc = userData.docs[0];

          final user = User(
            userId: userDoc['userId'],
            email: userDoc['email'],
            displayName: userDoc['displayName'],
            photoUrl: userDoc['photoUrl'],
            description: userDoc['description'],
          );

          final isLiked = isLikedTrip(likeIds, trip.id);

          if (isFavorite) {
            trips.add(Trip(
              id: trip.id,
              publicationDate: DateTime.fromMillisecondsSinceEpoch(
                  trip['publicationDate'].seconds * 1000),
              isPublic: trip['isPublic'],
              title: trip['title'],
              description: trip['description'],
              imageUrl: trip['imageUrl'],
              likesCount: int.parse(trip['likesCount'].toString()),
              cost: double.parse(trip['cost'].toString()),
              isLiked: isLiked,
              isFavorite: isFavoriteTrip(authFavoriteIds, trip.id),
              user: user,
            ));
          }
        }

        yield trips;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future likeTrip(String tripId, String userId) async {
    try {
      // Create data
      final Map<String, String> likeData = {
        'tripId': tripId,
        'userId': userId,
      };

      final trip = await _tripsCollection.doc(tripId).get();

      final Map<String, dynamic> updatedTrip = {
        'likesCount': trip['likesCount'] + 1,
      };

      await _likesCollection.add(likeData);
      await _tripsCollection.doc(trip.id).update(updatedTrip);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future dislikeTrip(String tripId, String userId) async {
    try {
      // Create data
      final likeDoc = await _likesCollection
          .where('userId', isEqualTo: userId)
          .where('tripId', isEqualTo: tripId)
          .get();

      final trip = await _tripsCollection.doc(tripId).get();

      final Map<String, dynamic> updatedTrip = {
        'likesCount': trip['likesCount'] - 1,
      };

      await _likesCollection.doc(likeDoc.docs[0].id).delete();
      await _tripsCollection.doc(trip.id).update(updatedTrip);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future addFavoriteTrip(String tripId, String userId) async {
    try {
      // Create data
      final Map<String, String> favoriteData = {
        'tripId': tripId,
        'userId': userId,
      };

      final trip = await _tripsCollection.doc(tripId).get();

      final Map<String, dynamic> updatedTrip = {
        'favoritesCount': trip['favoritesCount'] + 1,
      };

      await _favoritesCollection.add(favoriteData);
      await _tripsCollection.doc(trip.id).update(updatedTrip);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future deleteFavoriteTrip(String tripId, String userId) async {
    try {
      // Create data
      final favoriteDoc = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .where('tripId', isEqualTo: tripId)
          .get();

      final trip = await _tripsCollection.doc(tripId).get();

      final Map<String, dynamic> updatedTrip = {
        'favoritesCount': trip['favoritesCount'] - 1,
      };

      await _favoritesCollection.doc(favoriteDoc.docs[0].id).delete();
      await _tripsCollection.doc(trip.id).update(updatedTrip);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String> uploadTripPhoto(File photo) async {
    try {
      final fileName =
          'trip-image-${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      final ref = _firebaseStorage.ref().child('trips_images').child(fileName);

      final res = await ref.putFile(photo);
      final url = await ref.getDownloadURL();

      final photoUrl = res.metadata != null ? url.toString() : '';

      return photoUrl;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> createTrip({
    required String title,
    required String description,
    required String imageUrl,
    required String cost,
    bool? isPublic = false,
  }) async {
    try {
      final user = await authUser.first;
      // Create data
      final Map<String, dynamic> tripData = {
        'userId': user.id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'cost': double.parse(cost),
        'favoritesCount': 0,
        'likesCount': 0,
        'publicationDate': DateTime.now(),
        'isPublic': isPublic,
      };

      await _tripsCollection.add(tripData);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateTrip({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String cost,
    bool? isPublic = false,
  }) async {
    try {
      final user = await authUser.first;
      // Create data
      final Map<String, dynamic> tripData = {
        'userId': user.id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'cost': double.parse(cost),
        'publicationDate': DateTime.now(),
        'isPublic': isPublic,
      };

      await _tripsCollection.doc(id).update(tripData);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      await _tripsCollection.doc(id).delete();
    } catch (error) {
      throw Exception(error);
    }
  }
}

extension on _firebaseAuth_.User {
  AuthUser get toAuthUser {
    return AuthUser(
      id: uid,
      email: email,
    );
  }
}
