import 'package:firebase_auth/firebase_auth.dart';

/// Converts low-level [FirebaseAuthException] codes into short, friendly
/// messages suitable for SnackBars on the auth screens.
String friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password. Please try again.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'email-already-in-use':
      return 'An account already exists with this email. Try logging in instead.';
    case 'weak-password':
      return 'Password is too weak. Please use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'operation-not-allowed':
      return 'Email/Password sign-in is not enabled for this Firebase project.';
    case 'user-token-expired':
    case 'invalid-verification-code':
      return 'Your session expired. Please try again.';
    default:
      return e.message ?? 'Something went wrong. Please try again.';
  }
}
