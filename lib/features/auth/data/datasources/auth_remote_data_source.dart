import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sample_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<firebase_auth.UserCredential> login(String email, String password);
  Future<firebase_auth.UserCredential> signUp(String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>?> getUserData(String uid);
  Future<void> saveUserData(UserModel user, String department);
  Stream<firebase_auth.User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  @override
  Future<firebase_auth.UserCredential> login(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  @override
  Future<firebase_auth.UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Future<void> saveUserData(UserModel user, String department) {
    return _db.collection('users').doc(user.id).set({
      ...user.toMap(),
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
}
