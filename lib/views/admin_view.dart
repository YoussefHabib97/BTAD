import 'package:btad/screens/alzheimers_screen.dart';
import 'package:btad/screens/brain_tumor_screen.dart';
import 'package:flutter/material.dart';

import 'package:btad/helpers/firebase_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${auth.currentUser!.email}"),
        actions: [
          IconButton(
              onPressed: () {
                signOut(context);
              },
              icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket))
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AlzheimersScreen(),
                    ),
                  );
                },
                leading: const FaIcon(FontAwesomeIcons.handsBubbles),
                title: const Text("Alzheimer's"),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BrainTumorScreen(),
                    ),
                  );
                },
                leading: const FaIcon(FontAwesomeIcons.brain),
                title: const Text("Brain Tumor"),
              ),
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text("Admin View"),
      ),
    );
  }
}
