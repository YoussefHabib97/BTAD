import 'package:flutter/material.dart';

class PatientView extends StatelessWidget {
  const PatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [GridTile(child: Text("Hello"))],
    );
  }
}
