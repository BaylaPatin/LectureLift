import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered. Please sign in instead.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'weak-password':
          throw Exception('Password is too weak. Please use a stronger password.');
        default:
          throw Exception('Signup failed: ${e.message}');
      }
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Validate LSU email domain
  static bool isValidLSUEmail(String email) {
    return email.trim().toLowerCase().endsWith('@lsu.edu');
  }
}

