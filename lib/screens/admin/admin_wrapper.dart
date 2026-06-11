import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_home.dart';
import '../home_screen.dart';

class AdminWrapper extends StatelessWidget {
  const AdminWrapper({super.key});

  Future<String> getRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "user";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc['role'] ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == "admin") {
          return const AdminHome();
        }

        return const HomeScreen();
      },
    );
  }
}