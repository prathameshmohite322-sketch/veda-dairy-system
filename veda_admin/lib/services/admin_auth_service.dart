import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_session_user.dart';

class AdminAuthService {
  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<AdminSessionUser?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = credential.user;
    if (user == null) {
      return null;
    }
    return currentAdminUser();
  }

  Future<AdminSessionUser?> currentAdminUser() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final Map<String, dynamic> data = snapshot.data()!;
    final String role = _normalizeRole((data['role'] as String?) ?? '');
    if (role != 'admin') {
      return AdminSessionUser(
        id: user.uid,
        name: (data['name'] as String?) ?? (user.email ?? 'User'),
        email: (data['email'] as String?) ?? (user.email ?? ''),
        role: role,
      );
    }

    return AdminSessionUser(
      id: user.uid,
      name: (data['name'] as String?) ?? (user.email ?? 'Admin'),
      email: (data['email'] as String?) ?? (user.email ?? ''),
      role: role,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _normalizeRole(String value) {
    return value.replaceAll('"', '').trim().toLowerCase();
  }
}
