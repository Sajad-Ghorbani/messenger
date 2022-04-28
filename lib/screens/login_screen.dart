import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/methods.dart';
import 'package:messenger/screens/receive_code_screen.dart';
import 'package:messenger/widgets/base_widget.dart';
import 'package:messenger/widgets/custom_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String myVerificationId = '-1';
  TextEditingController userNameController = TextEditingController();

  TextEditingController passController = TextEditingController();
  bool textEmpty = true;
  late Size size;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
            height: size.height,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.3,
                ),
                Image.asset(
                  'assets/images/logo_messenger.png',
                  width: 200,
                ),
                const Spacer(),
                TextField(
                  controller: userNameController,
                  onChanged: (value) {
                    setState(() {
                      if (userNameController.text.isNotEmpty &
                          passController.text.isNotEmpty) {
                        textEmpty = false;
                      } //
                      else {
                        textEmpty = true;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Phone number or Email',
                    hintStyle: kHintText,
                  ),
                ),
                TextField(
                  controller: passController,
                  onChanged: (value) {
                    setState(() {
                      if (userNameController.text.isNotEmpty &&
                          passController.text.isNotEmpty) {
                        textEmpty = false;
                      } //
                      else {
                        textEmpty = true;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: kHintText,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                CustomButton(
                  text: 'LOG IN',
                  onTapped: () {
                    onLoginPressed();
                  },
                  color: textEmpty ? Colors.grey : Colors.black,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  text: 'CREATE YOUR ACCOUNT',
                  onTapped: () {
                    kNavigator(context, 'receive');
                  },
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: kTextContent.copyWith(color: kRedColor),
                    )),
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

  void onLoginPressed()async {
    String phone = userNameController.text;
    setState(() {
      loading = true;
    });
    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async{

      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          loading = false;
        });
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              duration: const Duration(seconds: 3),
              content: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kGreyColor.withOpacity(0.9),
                ),
                child: const Text(
                  'The provided phone number is not valid.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          );
        }
        print('********* error ***********');
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        print('********* code sent ********');
        print(verificationId);
        myVerificationId = verificationId;
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiveCodeScreen(myVerificationId: myVerificationId,),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
