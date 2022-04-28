import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/widgets/base_widget.dart';
import 'package:messenger/widgets/custom_button.dart';

import '../constants.dart';
import '../methods.dart';

class CompleteProfileScreen extends StatelessWidget {
  CompleteProfileScreen({Key? key}) : super(key: key);
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController(),
      usernameController = TextEditingController();
  CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              Image.asset(
                'assets/images/logo_messenger.png',
                width: 200,
              ),
              const Spacer(),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'full name',
                  hintStyle: kHintText,
                ),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'username',
                  hintStyle: kHintText,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              CustomButton(
                text: 'Register',
                onTapped: () {
                  onRegisterPressed(context);
                },
                color: Colors.black,
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onRegisterPressed(ctx) async {
    String name = nameController.text;
    String username = usernameController.text;
    await auth.currentUser!.updateDisplayName(name);
    usersRef.doc(auth.currentUser?.uid).update({
      'username': username,
      'name': name,
    });
    kNavigator(ctx, 'home');
  }
}
