import 'package:btad/screens/home_screen.dart';
import 'package:flutter/material.dart';

// Library imports
import 'dart:async';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget imports
import 'package:btad/widgets/email_verification.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _cloudFirestore = FirebaseFirestore.instance;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  Timer? timer;

  String role = '';

  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser!;
      await user.sendEmailVerification();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  // Check if user is verified in initial state
  @override
  void initState() {
    super.initState();

    _isEmailVerified = _firebaseAuth.currentUser!.emailVerified;
    // Check account role

    if (!_isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    }

    // Check account role after verification
    checkAccountRole();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Refresh the user to see if they're already verified
    await _firebaseAuth.currentUser!.reload();

    setState(() {
      _isEmailVerified = _firebaseAuth.currentUser!.emailVerified;
    });
    if (_isEmailVerified) timer?.cancel();
  }

  Future<void> checkAccountRole() async {
    // Get current user data by using their unique id provided by firebase auth
    final currentUserData = await _cloudFirestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get();

    if (currentUserData['role'] == 'admin') {
      setState(() {
        role = 'admin';
      });
    }
    if (currentUserData['role'] == 'doctor') {
      setState(() {
        role = 'doctor';
      });
    }
    if (currentUserData['role'] == 'patient') {
      setState(() {
        role = 'patient';
      });
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return !_isEmailVerified
        ? EmailVerificationWidget(signOut: signOut)
        : HomeScreen(
            role: role,
            user: _firebaseAuth.currentUser!,
          );
  }
}
