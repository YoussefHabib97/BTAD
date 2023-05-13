import 'package:btad/screens/home_screen.dart';
import 'package:flutter/material.dart';

// Package imports
import 'package:google_fonts/google_fonts.dart';

// Firebase SDK imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screen imports
import 'package:btad/screens/authentication_screen.dart';
import 'package:btad/screens/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());

    if (inDebugMode) {
      return ErrorWidget(details.exception);
    }
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Error\n${details.exception}",
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        textAlign: TextAlign.center,
      ),
    );
  };

  runApp(const ApplicationRoot());
}

class ApplicationRoot extends StatelessWidget {
  const ApplicationRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BTAD",
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorSchemeSeed: Colors.deepPurpleAccent,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            if (FirebaseAuth.instance.currentUser == null) {
              return const AuthenticationScreen();
            } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
              return const VerifyEmailScreen();
            }
            return HomeScreen(user: FirebaseAuth.instance.currentUser!);
          }
          return const AuthenticationScreen();
        },
      ),
    );
  }
}
