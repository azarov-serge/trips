import 'dart:async';

import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart' as _firebaseAuth_;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cache/cache.dart';
import 'package:trips/services/services.dart';

/// Service which manages user authentication.
class AuthService {
  AuthService();

  final CacheClient _cache = CacheClient();
  final _firebaseAuth_.FirebaseAuth _firebaseAuth = firebaseAuth;
  final FirebaseFirestore _firebaseFirestore = firebaseFirestore;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  CollectionReference get _usersCollection =>
      _firebaseFirestore.collection('users');

  CollectionReference get _followersCollection =>
      _firebaseFirestore.collection('followers');

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

  Future get following async {
    final user = await authUser.first;

    return await _followersCollection
        .where('followerId', isEqualTo: user.id)
        .get();
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
        email: email.toLowerCase(),
        password: password,
      );

      // Create data for user's profile
      final userData = <String, String>{
        'userId': _firebaseAuth.currentUser?.uid ?? '',
        'email': email.toLowerCase(),
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
        email: email.toLowerCase(),
        password: password,
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  /// Signs out the current user which will emit
  /// [AuthUser.empty] from the [user] Stream.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
      ]);
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
