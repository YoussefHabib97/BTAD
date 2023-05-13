import 'package:flutter/material.dart';

// Library imports
import 'dart:async';

// Package imports
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screen imports
import 'package:btad/screens/home_screen.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _cloudFirestore = FirebaseFirestore.instance;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  bool _isEnabled = false;

  late final AnimationController _controller;

  bool _isEmailVerified = false;
  Timer? timer;

  String role = '';

  bool canResendEmail = true;
  static const int totalWaitTime = 60;
  int currentWaitTime = 60;

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentWaitTime > 0) {
          currentWaitTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void resetCountdown() {
    setState(() {
      currentWaitTime = totalWaitTime;
      timer?.cancel();
    });
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      startCountdown();
      await Future.delayed(Duration(seconds: currentWaitTime));
      setState(() {
        _isEnabled = true;
        canResendEmail = true;
      });
      resetCountdown();
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _isEmailVerified = _firebaseAuth.currentUser!.emailVerified;

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
    _controller.dispose();
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

    switch (currentUserData['role']) {
      case 'admin':
        setState(() {
          role = 'admin';
        });
        break;
      case 'doctor':
        setState(() {
          role = 'doctor';
        });
        break;
      case 'patient':
        setState(() {
          role = 'patient';
        });
        break;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    if (!_isEmailVerified) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Verify Email"),
          actions: [
            IconButton(
              onPressed: signOut,
              icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("A verification email has been sent to:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  "${_firebaseAuth.currentUser!.email}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withAlpha(250),
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please check your inbox or spam folder.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).cardColor,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: !_isEnabled
                      ? null
                      : canResendEmail
                          ? sendVerificationEmail
                          : null,
                  icon: const FaIcon(FontAwesomeIcons.envelope),
                  label: const Text("Resend Email"),
                ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: canResendEmail ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  // onEnd: resetCountdown,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                          value: currentWaitTime / totalWaitTime),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(64),
                        ),
                        width: 64,
                        height: 64,
                        child: Text(
                          currentWaitTime.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 24,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return HomeScreen(
        user: _firebaseAuth.currentUser!,
      );
    }
  }
}
