import '../auth/firebase_auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthServiceProvider.instance;

  Future<String> signIn(String email, String password) async {
    final token = await _authService.signIn(email, password);
    if (token == null) {
      throw Exception('Failed to sign in');
    }
    return token;
  }

  Future<String> signUp(String email, String password) async {
    final token = await _authService.signUp(email, password);
    if (token == null) {
      throw Exception('Failed to sign up');
    }
    return token;
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
