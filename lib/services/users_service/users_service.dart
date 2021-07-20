import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trips/services/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as _firebaseAuth_;
import 'package:cache/cache.dart';

/// Service which manages users.
class UsersService {
  UsersService();

  final FirebaseFirestore _firebaseFirestore = firebaseFirestore;
  final FirebaseStorage _firebaseStorage = firebaseStorage;
  final _firebaseAuth_.FirebaseAuth _firebaseAuth = firebaseAuth;
  final CacheClient _cache = CacheClient();

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  CollectionReference get _usersCollection =>
      _firebaseFirestore.collection('users');

  CollectionReference get _tripsCollection =>
      _firebaseFirestore.collection('trips');

  CollectionReference get _followersCollection =>
      _firebaseFirestore.collection('followers');

  Stream<AuthUser> get authUser {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user =
          firebaseUser == null ? AuthUser.empty : firebaseUser.toAuthUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Get user by id in collection users
  Stream<QuerySnapshot> getUserByUserId(String userId) {
    return _usersCollection.where('userId', isEqualTo: userId).snapshots();
  }

  /// Get user's trips ids by user id in collection trips
  Stream<List<String>> getTripsIdsByUserId(String userId) async* {
    try {
      final snapshots =
          _tripsCollection.where('userId', isEqualTo: userId).snapshots();

      await for (final snapshot in snapshots) {
        final List<String> ids = [];
        snapshot.docs.forEach((doc) {
          ids.add(doc.id);
        });
        yield ids;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Get followers's ids by user id in collection followers
  Stream<List<String>> getFollowersIdsByUserId(String userId) async* {
    try {
      final snapshots =
          _followersCollection.where('userId', isEqualTo: userId).snapshots();

      await for (final snapshot in snapshots) {
        final List<String> ids = [];
        snapshot.docs.forEach((doc) {
          ids.add(doc['followerId'].toString());
        });
        yield ids;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Get following's ids by user id in collection following
  Stream<List<String>> getFollowingIdsByUserId(String userId) async* {
    try {
      final snapshots = _followersCollection
          .where('followerId', isEqualTo: userId)
          .snapshots();

      await for (final snapshot in snapshots) {
        final List<String> ids = [];
        snapshot.docs.forEach((doc) {
          ids.add(doc['userId'].toString());
        });
        yield ids;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Get following's list by user id in collection following
  Stream<QuerySnapshot> getUsersListByIds(List<String> usersIds) {
    return _usersCollection.where('userId', whereIn: usersIds).snapshots();
  }

  Future<List<String>> getFollowersIds(String userId) async {
    try {
      final List<String> ids = [];
      final data =
          await _followersCollection.where('userId', isEqualTo: userId).get();

      data.docs.forEach((doc) {
        ids.add(doc['followerId']);
      });

      return ids;
    } catch (error) {
      throw Exception(error);
    }
  }

  Stream<List<User>> getFollowers(String usersId) async* {
    try {
      final usersIds = await getFollowersIds(usersId);
      final snapshots =
          _usersCollection.where('userId', whereIn: usersIds).snapshots();

      await for (final snapshot in snapshots) {
        final List<User> users = [];
        snapshot.docs.forEach((doc) {
          users.add(User(
            userId: doc['userId'],
            email: doc['email'],
            displayName: doc['displayName'],
            photoUrl: doc['photoUrl'],
            description: doc['description'],
          ));
        });

        yield users;
      }
    } catch (error) {
      throw Exception(error);
    }
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

  Stream<List<User>> getFollowing(String usersId) async* {
    try {
      final usersIds = await getFollowingIds(usersId);
      final snapshots =
          _usersCollection.where('userId', whereIn: usersIds).snapshots();

      await for (final snapshot in snapshots) {
        final List<User> users = [];
        snapshot.docs.forEach((doc) {
          users.add(User(
            userId: doc['userId'],
            email: doc['email'],
            displayName: doc['displayName'],
            photoUrl: doc['photoUrl'],
            description: doc['description'],
          ));
        });

        yield users;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Remove follower
  Future<void> removeFollower(userId) async {
    try {
      final data = await _followersCollection
          .where('followerId', isEqualTo: userId)
          .get();
      final docId = data.docs.first.id;

      await _followersCollection.doc(docId).delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Remove following
  Future<void> removeFollowing(userId) async {
    try {
      final data =
          await _followersCollection.where('userId', isEqualTo: userId).get();
      final docId = data.docs.first.id;

      await _followersCollection.doc(docId).delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Search user by name in collection users
  Future<List<User>> searchUserByName(String text) async {
    try {
      final result =
          await _usersCollection.where('displayName', isEqualTo: text).get();

      final List<User> users = result.docs.length > 0
          ? result.docs
              .map(
                (doc) => User(
                  userId: doc['userId'],
                  email: doc['email'],
                  displayName: doc['displayName'],
                  photoUrl: doc['photoUrl'],
                  description: doc['description'],
                ),
              )
              .toList()
          : [];

      return users;
    } catch (error) {
      print('ERROR ${error.toString()}');
      throw Exception(error);
    }
  }

  /// Follow user
  Future<void> follow(String userId) async {
    try {
      final user = await authUser.first;
      // Create data
      final followerData = <String, String>{
        'userId': userId,
        'followerId': user.id,
      };

      await _followersCollection.add(followerData);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> getUserData(String userId) async {
    final userData =
        await _usersCollection.where(userId, isEqualTo: userId).get();
    return userData.docs.length != 0
        ? User(
            userId: userData.docs.first['userId'],
            email: userData.docs.first['email'],
            displayName: userData.docs.first['displayName'],
            photoUrl: userData.docs.first['photoUrl'] ?? '',
            description: userData.docs.first['description'] ?? '',
          )
        : User.empty;
  }

  Future<String> getDocIdByUserId(String userId) async {
    try {
      final userData =
          await _usersCollection.where('userId', isEqualTo: userId).get();

      return userData.docs.first.id;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String> updateUserPhoto(String userId, File photo) async {
    try {
      final ref =
          _firebaseStorage.ref().child('users_images').child('$userId.jpg');

      final res = await ref.putFile(photo);
      final url = await ref.getDownloadURL();

      final photoUrl = res.metadata != null ? url.toString() : '';

      return photoUrl;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String photoUrl,
    required String displayName,
    required String description,
  }) async {
    try {
      final docId = await getDocIdByUserId(userId);

      final Map<String, String> updatedData = {
        'photoUrl': photoUrl,
        'displayName': displayName,
        'description': description,
      };
      await _usersCollection.doc(docId).update(updatedData);
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
