import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/screens/contact_screen.dart';
import 'package:messenger/screens/home_screen.dart';

FirebaseAuth auth = FirebaseAuth.instance;

String kGetTime(DateTime lastSign) {
  int time = DateTime.now().difference(lastSign).inHours;
  if (time < 48) return 'last seen recently';
  if (time >= 48 && time < 168) return 'last seen less than a week';
  return 'last seen... ';
}

kNavigator(context, String text) async {
  if (text == 'home') {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .update({
      'isActive': true,
      'lastSignedIn': DateTime.now(),
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  } else if (text == 'contact') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactScreen(),
      ),
    );
  }
}
