class AuthRepository {
  Future<String> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'fail@example.com') throw Exception('Invalid credentials');
    return 'dev-token-$email';
  }

  Future<String> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'dev-token-$email';
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
