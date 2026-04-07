import '../models/app_user.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> signIn({
    required String phone,
    required String password,
  }) async {
    if (phone.isEmpty || password.isEmpty) {
      return null;
    }

    _currentUser = AppUser(
      id: 'u1',
      dairyId: 'dairy_veda_001',
      name: 'Prathamesh Mohite',
      role: phone.endsWith('00') ? 'owner' : 'staff',
      phone: phone,
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
