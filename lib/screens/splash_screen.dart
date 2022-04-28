import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/methods.dart';
import 'package:messenger/widgets/base_widget.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');

  String _connectionStatus = '-1';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = 'wifi net');
        break;
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = 'mobile net');
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = '-1');
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
                '''No internet connection.
Please turn on mobile data or wifi''',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        );
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
    if (_connectionStatus != '-1') {
      Future.delayed(const Duration(seconds: 3), () {
        if (auth.currentUser != null) {
          kNavigator(context, 'home');
        } //
        else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Center(
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/logo_messenger.png',
              width: 200,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'from',
                    style: kTextContent.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Tosegar',
                    style: kHeaderText,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
