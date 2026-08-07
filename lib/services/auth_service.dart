import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
