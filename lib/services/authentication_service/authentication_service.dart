import 'dart:async';

import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cache/cache.dart';
import 'package:trips/services/services.dart';

/// Service which manages user authentication.
class AuthenticationService {
  AuthenticationService();

  final CacheClient _cache = CacheClient();
  final firebaseAuth.FirebaseAuth _firebaseAuth =
      firebaseAuth.FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  CollectionReference get _usersCollection =>
      _firebaseFirestore.collection('users');

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthUser.empty] if the user is not authenticated.
  Stream<AuthUser> get authUser {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user =
          firebaseUser == null ? AuthUser.empty : firebaseUser.toAuthUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [AuthUser.empty] if there is no cached user.
  AuthUser get currentUser {
    return _cache.read<AuthUser>(key: userCacheKey) ?? AuthUser.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create data for user's profile
      final userData = <String, String>{
        'userId': _firebaseAuth.currentUser?.uid ?? '',
        'email': email,
        'displayName': displayName,
        'photoUrl': '',
        'description': '',
      };
      // Create user's profile
      await _usersCollection.add(userData);
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Signs in with the provided [email] and [password].
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
      ]);
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Search user by name in collection users
  Future searchUserByName(String text) async {
    try {
      final result = await _firebaseFirestore
          .collection('users')
          .where('displayName', isEqualTo: text)
          .get();
      return result;
    } catch (error) {
      throw Exception(error);
    }
  }
}

extension on firebaseAuth.User {
  AuthUser get toAuthUser {
    return AuthUser(
      id: uid,
      email: email,
    );
  }
}
