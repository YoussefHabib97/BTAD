import 'package:flutter/material.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// View imports
import 'package:btad/views/admin_view.dart';
import 'package:btad/views/doctor_view.dart';
import 'package:btad/views/patient_view.dart';

class AdaptiveViewWidget extends StatefulWidget {
  final User user;

  const AdaptiveViewWidget({super.key, required this.user});

  @override
  State<AdaptiveViewWidget> createState() => _AdaptiveViewWidgetState();
}

class _AdaptiveViewWidgetState extends State<AdaptiveViewWidget> {
  String role = '';
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.email)
        .get();

    setState(() {
      role = currentUserData['role'];
      firstName = currentUserData['first_name'];
      lastName = currentUserData['last_name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (role == 'admin') return const AdminView();
    if (role == 'doctor') return const DoctorView();
    if (role == 'patient') return const PatientView();
    return const Center(child: CircularProgressIndicator());
  }
}
