import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/methods.dart';
import 'package:messenger/screens/complete_profile_screen.dart';
import 'package:messenger/widgets/base_widget.dart';
import 'package:messenger/widgets/custom_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';

class ReceiveCodeScreen extends StatefulWidget {
  const ReceiveCodeScreen({Key? key, required this.myVerificationId})
      : super(key: key);
  final String myVerificationId;

  @override
  State<ReceiveCodeScreen> createState() => _ReceiveCodeScreenState();
}

class _ReceiveCodeScreenState extends State<ReceiveCodeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController codeController = TextEditingController();

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  late CollectionReference usersRef;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersRef = fireStore.collection('Users');
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      color: Colors.black,
      opacity: 0.6,
      progressIndicator: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(15),
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
      child: BaseWidget(
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
                  controller: codeController,
                  decoration: InputDecoration(
                    hintText: 'code xxxx',
                    hintStyle: kHintText,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                CustomButton(
                  text: 'Next',
                  onTapped: () {
                    onButtonPressed(context);
                  },
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Did not receive?',
                    style: kTextContent.copyWith(color: kRedColor),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onButtonPressed(ctx) async {
    setState(() {
      loading = true;
    });
    String smsCode = codeController.text;
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.myVerificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          duration: const Duration(seconds: 5),
          content: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kGreyColor.withOpacity(0.9),
            ),
            child: const Text(
              'The sms verification code used to create the phone auth credential is invalid.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      );
    }
    Map<String, dynamic> newMap = {};
    newMap['userId'] = auth.currentUser!.uid;
    newMap['name'] = '';
    newMap['username'] = '';
    newMap['phoneNumber'] = auth.currentUser!.phoneNumber;
    newMap['lastSignedIn'] = auth.currentUser!.metadata.lastSignInTime;
    newMap['createdTime'] = auth.currentUser!.metadata.creationTime;
    newMap['imageAddress'] = '';
    newMap['isActive'] = true;
    newMap['isTyping'] = false;
    QuerySnapshot snapshot = await usersRef
        .where('userId', isEqualTo: auth.currentUser!.uid)
        .limit(1)
        .get();
    List list = snapshot.docs;
    if (list.length == 1) {
      kNavigator(context, 'home');
      setState(() {
        loading = false;
      });
    } //
    else {
      await usersRef.doc(auth.currentUser!.uid).set(newMap);
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) => CompleteProfileScreen(),
          ));
    }
  }
}
