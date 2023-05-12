import 'package:flutter/material.dart';

// Package imports
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailVerificationWidget extends StatelessWidget {
  final void Function() signOut;
  const EmailVerificationWidget({super.key, required this.signOut});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
