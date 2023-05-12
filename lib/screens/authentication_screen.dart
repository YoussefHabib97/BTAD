import 'package:flutter/material.dart';

// Package imports
import 'package:email_validator/email_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:string_capitalize/string_capitalize.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

List<String> accountTypes = [
  'admin',
  'doctor',
  'patient',
];

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  // Form parameters
  final _formKey = GlobalKey<FormState>();
  late String _enteredEmail;
  late String _enteredPassword;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordIsVisible = false;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  // Authentication
  bool _isAuthenticating = false;
  Future<void> _authenticate() async {
    bool isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    try {
      // Trigger loading spinner by flagging the authentication boolean
      setState(() {
        _isAuthenticating = true;
      });

      if (!_isLogin) {
        // Sign users up

        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);

        // Create a document of the user using their uid and set custom fields
        await _firebaseFirestore
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'email': _enteredEmail,
          'role': currentOption,
        });
      } else {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication failed"),
          action: SnackBarAction(
            label: "Dismiss",
            onPressed: () => ScaffoldMessenger.of(context).clearSnackBars(),
          ),
          duration: const Duration(days: 1),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  String currentOption = accountTypes[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          !_isLogin ? "Sign Up" : "Sign In",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 256,
                  margin: const EdgeInsets.only(
                    top: 32,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.personDress,
                    size: 256,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                suffix: _emailController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () =>
                                            _emailController.clear(),
                                        icon: const FaIcon(
                                          FontAwesomeIcons.xmark,
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (value) => _enteredEmail = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email address";
                                }
                                if (!EmailValidator.validate(value)) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordIsVisible,
                              decoration: InputDecoration(
                                suffix: _passwordController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _passwordIsVisible =
                                                !_passwordIsVisible;
                                          });
                                        },
                                        icon: !_passwordIsVisible
                                            ? const FaIcon(FontAwesomeIcons.eye)
                                            : const FaIcon(
                                                FontAwesomeIcons.eyeSlash),
                                      )
                                    : null,
                                labelText: 'Password',
                              ),
                              onChanged: (value) => _enteredPassword = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Please enter at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            if (!_isLogin)
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Column(
                                    children: [
                                      RadioListTile(
                                        value: accountTypes[0],
                                        groupValue: currentOption,
                                        title: Text(
                                          accountTypes[0].capitalize(),
                                        ),
                                        onChanged: !_isAuthenticating
                                            ? (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              }
                                            : null,
                                      ),
                                      RadioListTile(
                                        value: accountTypes[1],
                                        groupValue: currentOption,
                                        onChanged: !_isAuthenticating
                                            ? (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              }
                                            : null,
                                        title: Text(
                                          accountTypes[1].capitalize(),
                                        ),
                                      ),
                                      RadioListTile(
                                        value: accountTypes[2],
                                        groupValue: currentOption,
                                        onChanged: !_isAuthenticating
                                            ? (value) {
                                                setState(() {
                                                  currentOption =
                                                      value.toString();
                                                });
                                              }
                                            : null,
                                        title: Text(
                                          accountTypes[2].capitalize(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            !_isLogin
                                ? const SizedBox(height: 8)
                                : const SizedBox(height: 16),
                            !_isAuthenticating
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: _authenticate,
                                        child: Text(
                                          !_isLogin ? "Sign Up" : "Sign In",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isLogin = !_isLogin;
                                            setState(() {
                                              _formKey.currentState!.reset();
                                              _emailController.clear();
                                              _passwordController.clear();
                                            });
                                          });
                                        },
                                        child: Text(
                                          !_isLogin
                                              ? "I already have an account"
                                              : "I don't have an account",
                                        ),
                                      ),
                                    ],
                                  )
                                : const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
