import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  Future<String?> signIn(String email, String password) async {
    UserCredential credential;

    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('No user found for that email');
      } else if (e.code == 'wrong-password') {
        return ('Wrong password provided for that user');
      }
      return '${e.message}';
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> signUp(
      String email, String password, String firstName, String lastName) async {
    UserCredential credential;

    try {
      final credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await addUser(credential.user!, firstName, lastName);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email');
      }
      return '${e.message}';
    } catch (e) {
      return '$e';
    }
  }

  Future<String> addUser(User user, String firstName, String lastName) async {
    try {
      final docRef = await db.collection("users").add({
        'email': user.email,
        'firstname': firstName,
        'lastname': lastName,
      });
      await db.collection("users").doc(docRef.id).update({'id': docRef.id});

      return "Successfully added user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
