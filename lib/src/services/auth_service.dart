import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User> currentUser() =>_auth.authStateChanges();

  Future<UserCredential> signupEmail(String email, String password) {
     return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signinEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signinWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  User user() => _auth.currentUser;
  Future<void> signOut() => _auth.signOut();
  Future<void> verifyEmail() => _auth.currentUser.sendEmailVerification();
  Future<void> sendResetPassword () => _auth.sendPasswordResetEmail(email: _auth.currentUser.email);
}