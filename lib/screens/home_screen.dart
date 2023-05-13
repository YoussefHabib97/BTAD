import 'package:flutter/material.dart';

// Package imports
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String role = '';

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> getUserRole() async {
    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    setState(() {
      role = currentUserData['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepPurple[200],
      appBar: AppBar(
        title: Text(widget.user.email!),
        // backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
            ),
          )
        ],
      ),
      body: LiquidPullToRefresh(
        color: Colors.deepPurpleAccent,
        showChildOpacityTransition: false,
        backgroundColor: Colors.deepPurple[200],
        animSpeedFactor: 3,
        onRefresh: handleRefresh,
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  // color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
