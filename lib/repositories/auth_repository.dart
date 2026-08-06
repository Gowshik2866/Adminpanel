import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sample_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_app/core/enums.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) {
        // Return a default basic user if not registered in firestore yet
        return User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Unknown',
          email: firebaseUser.email ?? '',
          role: Role.other,
          lastLogin: DateTime.now(),
        );
      }
      return User.fromFirestore(doc);
    });
  }

  Future<void> login(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    Role role = Role.other,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser != null) {
      await firebaseUser.updateDisplayName(name);
      final user = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: role,
        lastLogin: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toFirestore());
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? get currentUser {
    final u = _firebaseAuth.currentUser;
    if (u == null) return null;
    return User(
      id: u.uid,
      name: u.displayName ?? 'Unknown',
      email: u.email ?? '',
      role: Role.other,
      lastLogin: DateTime.now(),
    );
  }
}
