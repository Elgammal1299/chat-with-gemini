import 'package:firebase_auth/firebase_auth.dart';

class FireBaseServices {
  final instance = FirebaseAuth.instance;
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
    // try {
    //   final userCredential = await instance.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    //   return userCredential;
    // } catch (e) {
    //   log('Error signing in: $e');
    //   throw Exception('Failed to sign in: $e');
    // }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
    //   try {
    //     final userCredential = await instance.createUserWithEmailAndPassword(
    //       email: email,
    //       password: password,
    //     );
    //     return userCredential;
    //   } catch (e) {
    //     log('Error creating user: $e');
    //     throw Exception('Failed to create user: $e');
    //   }
  }
}
