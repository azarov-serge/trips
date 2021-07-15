import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trips/services/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service which manages users.
class UsersService {
  UsersService();

  final FirebaseFirestore _firebaseFirestore = firebaseFirestore;
  final FirebaseStorage _firebaseStorage = firebaseStorage;

  CollectionReference get _usersCollection =>
      _firebaseFirestore.collection('users');

  CollectionReference get _tripsCollection =>
      _firebaseFirestore.collection('trips');

  CollectionReference get _follwersCollection =>
      _firebaseFirestore.collection('followers');

  /// Get user by id in collection users
  Stream<QuerySnapshot> getUserByUserId(String userId) {
    return _usersCollection.where('userId', isEqualTo: userId).snapshots();
  }

  /// Get user's trips ids by user id in collection trips
  Stream<QuerySnapshot> getTripsIdsByUserId(String userId) {
    return _tripsCollection.where('userId', isEqualTo: userId).snapshots();
  }

  /// Get followers's ids by user id in collection followers
  Stream<QuerySnapshot> getFollowersIdsByUserId(String userId) {
    return _follwersCollection.where('userId', isEqualTo: userId).snapshots();
  }

  /// Get following's ids by user id in collection following
  Stream<QuerySnapshot> getFollowingIdsByUserId(String userId) {
    return _follwersCollection
        .where('followerId', isEqualTo: userId)
        .snapshots();
  }

  /// Get following's list by user id in collection following
  Stream<QuerySnapshot> getUsersListByIds(List<String> usersIds) {
    return _usersCollection.where('userId', whereIn: usersIds).snapshots();
  }

  /// Remove follower
  Future<void> removeFollower(userId) async {
    try {
      final data = await _follwersCollection
          .where('followerId', isEqualTo: userId)
          .get();
      final docId = data.docs.first.id;

      await _follwersCollection.doc(docId).delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Remove following
  Future<void> removeFollowing(userId) async {
    try {
      final data =
          await _follwersCollection.where('userId', isEqualTo: userId).get();
      final docId = data.docs.first.id;

      await _follwersCollection.doc(docId).delete();
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
  Future<void> follow(String userId, String followerId) async {
    try {
      // Create data
      final followerData = <String, String>{
        'userId': userId,
        'followerId': followerId,
      };

      await _follwersCollection.add(followerData);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> getUserData(String userId) async {
    final userData =
        await _usersCollection.where(userId, isEqualTo: userId).get();
    return userData.docs.first != null
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
    final userData =
        await _usersCollection.where('userId', isEqualTo: userId).get();

    return userData.docs.first.id;
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
