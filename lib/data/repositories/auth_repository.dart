class AuthRepository {
  // Replace these stubs with real implementation (Firebase, backend, etc.)
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
    // no-op for stub
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
