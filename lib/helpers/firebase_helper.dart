import 'package:flutter/material.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

void showScaffoldMessenger(BuildContext context, FirebaseException error) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error.message ?? "Something went wrong",
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

Future<void> signUp({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String role,
  required BuildContext context,
}) async {
  try {
    await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await firestore.collection('users').doc(email).set({
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    });
  } on FirebaseAuthException catch (error) {
    showScaffoldMessenger(context, error);
  }
}

Future<void> signIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (error) {
    showScaffoldMessenger(context, error);
  }
}

Future<void> signOut(BuildContext context) async {
  try {
    await firebaseAuth.signOut();
  } on FirebaseAuthException catch (error) {
    showScaffoldMessenger(context, error);
  }
}

Future<void> getUserData({
  required User user,
  required BuildContext context,
}) {
  return fetchDocumentData(user: user, context: context);
}

Future<void> fetchDocumentData({
  required User user,
  required BuildContext context,
}) async {
  try {
    final currentUserData =
        await firestore.collection('users').doc(user.email).get();
    print(currentUserData);
  } on FirebaseException catch (error) {
    showScaffoldMessenger(context, error);
  }
}
