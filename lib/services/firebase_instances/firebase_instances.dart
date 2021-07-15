import 'package:firebase_auth/firebase_auth.dart' as _firebaseAuth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebaseAuth.FirebaseAuth firebaseAuth =
    _firebaseAuth.FirebaseAuth.instance;
final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
