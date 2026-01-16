import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_dart/firebase_dart.dart' as fb_dart;

/// Abstract auth service interface
abstract class AuthService {
  Future<String?> signIn(String email, String password);
  Future<String?> signUp(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  String? get currentUserToken;
  Stream<String?> get authStateChanges;
}

/// Firebase Auth service for mobile/web platforms
class FirebaseAuthService implements AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  @override
  Future<String?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user?.getIdToken();
  }

  @override
  Future<String?> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user?.getIdToken();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  String? get currentUserToken => null; // Token retrieved async

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) => user?.getIdToken());
}

/// Pure Dart Firebase Auth service for Linux
class FirebaseDartAuthService implements AuthService {
  fb_dart.FirebaseAuth? _auth;

  FirebaseDartAuthService(fb_dart.FirebaseApp app) {
    _auth = fb_dart.FirebaseAuth.instanceFor(app: app);
  }

  @override
  Future<String?> signIn(String email, String password) async {
    final credential = await _auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user?.getIdToken();
  }

  @override
  Future<String?> signUp(String email, String password) async {
    final credential = await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user?.getIdToken();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth!.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _auth!.signOut();
  }

  @override
  String? get currentUserToken => null; // Token retrieved async

  @override
  Stream<String?> get authStateChanges =>
      _auth!.authStateChanges().asyncMap((user) => user?.getIdToken());
}

/// Singleton to hold the auth service instance
class AuthServiceProvider {
  static AuthService? _instance;

  static AuthService get instance {
    if (_instance == null) {
      throw StateError('AuthService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  static void initialize(AuthService service) {
    _instance = service;
  }

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;
}
