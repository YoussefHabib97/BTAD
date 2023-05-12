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
  late final AnimationController _controller;
  late final Animation _animation;

  bool _isEmailVerified = false;
  Timer? timer;

  String role = '';

  bool canResendEmail = true;
  int timeLeft = 30;

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      startCountdown();
      await Future.delayed(Duration(seconds: timeLeft));
      setState(() {
        canResendEmail = true;
        timeLeft = 30;
      });
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
      duration: const Duration(seconds: 2),
    );

    _animation = Tween(begin: 0, end: 0).animate(_controller);

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
    _controller.forward();

    if (!_isEmailVerified) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: Text(
            "Verify Email",
            style: TextStyle(color: Theme.of(context).cardColor),
          ),
          actions: [
            IconButton(
              onPressed: signOut,
              icon: FaIcon(
                FontAwesomeIcons.arrowRightFromBracket,
                color: Theme.of(context).cardColor,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "A verification email has been sent to you.\nPlease check your inbox.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).cardColor,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: canResendEmail ? sendVerificationEmail : null,
                icon: const FaIcon(FontAwesomeIcons.envelope),
                label: const Text("Resend Email"),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: canResendEmail ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(512),
                  child: Container(
                    alignment: Alignment.center,
                    width: 64,
                    height: 64,
                    color: Theme.of(context).cardColor,
                    child: Text(
                      timeLeft.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                          ),
                    ),
                  ),
                ),
              ),
            ],
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
