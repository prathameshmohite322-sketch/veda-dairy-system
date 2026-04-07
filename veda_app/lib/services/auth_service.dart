import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> currentSessionUser() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    _currentUser = await _ensureUserProfile(user);
    return _currentUser;
  }

  Future<AppUser?> signIn({
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
    _currentUser = await _ensureUserProfile(user);
    return _currentUser;
  }

  Future<AppUser?> createOwnerAccount({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = credential.user;
    if (user == null) {
      return null;
    }
    _currentUser = await _ensureUserProfile(user);
    return _currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<AppUser> _ensureUserProfile(User user) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('users').doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    if (!snapshot.exists) {
      final String email = user.email ?? '';
      final String baseName = email.isEmpty ? 'Veda User' : email.split('@').first;
      final Map<String, dynamic> profile = <String, dynamic>{
        'name': baseName,
        'email': email,
        'phone': '',
        'role': 'owner',
        'dairyId': 'dairy_veda_001',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(profile);
      return AppUser(
        id: user.uid,
        dairyId: profile['dairyId'] as String,
        name: profile['name'] as String,
        role: profile['role'] as String,
        email: profile['email'] as String,
        phone: profile['phone'] as String,
      );
    }

    final Map<String, dynamic> data = snapshot.data()!;
    return AppUser(
      id: user.uid,
      dairyId: (data['dairyId'] as String?) ?? 'dairy_veda_001',
      name: (data['name'] as String?) ?? (user.email?.split('@').first ?? 'Veda User'),
      role: (data['role'] as String?) ?? 'owner',
      email: (data['email'] as String?) ?? (user.email ?? ''),
      phone: (data['phone'] as String?) ?? '',
    );
  }
}
