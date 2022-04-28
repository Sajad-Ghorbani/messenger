import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/base_widget.dart';
import 'package:messenger/widgets/edit_profile_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late CollectionReference userRef;
  TextEditingController usernameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  File file = File('-1');
  String myVerificationId = '-1';
  bool waitingForCode = false;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userRef = FirebaseFirestore.instance.collection('Users');
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
        appBar: AppBar(
          title: Text(
            'Me',
            style: kHeaderText,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: SizedBox(
                                height: 160,
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: file.path != '-1'
                                      ? Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                        )
                                      : auth.currentUser?.photoURL == null
                                          ? Image.asset(
                                              'assets/images/user-default.png',
                                              fit: BoxFit.cover,
                                            )
                                          : FadeInImage(
                                              placeholder: const AssetImage(
                                                  'assets/images/user-default.png'),
                                              image: NetworkImage(
                                                auth.currentUser?.photoURL ??
                                                    '',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                ),
                              ),
                              radius: 80,
                            ),
                            Positioned(
                              right: 5,
                              bottom: 5,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              selectImageFromCamera();
                                            },
                                            icon: const Icon(Icons.camera),
                                            label: Text(
                                              'From camera',
                                              style: kTextContent,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              selectImageFromGallery();
                                            },
                                            icon: const Icon(
                                              Icons.image,
                                            ),
                                            label: Text(
                                              'From gallery',
                                              style: kTextContent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    color: Colors.white,
                                  ),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLightBlueColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        auth.currentUser!.displayName ?? '',
                        style: kHeaderText,
                      ),
                      EditProfileButton(
                        onOKPressed: () {
                          onOKPressed();
                        },
                        phoneController: phoneController,
                        usernameController: usernameController,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Profile',
                  style: kHintText,
                ),
                FutureBuilder(
                  future: loadData(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      Map data = snapshot.data!.data() as Map;
                      return Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: kGreenColor,
                              radius: 25,
                              child: Icon(
                                Icons.offline_pin_rounded,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'Active Status',
                              style: kTextContent,
                            ),
                            subtitle:
                                Text(data['isActive'] ? 'online' : 'offline'),
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: kRedColor,
                              radius: 25,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'User Name',
                              style: kTextContent,
                            ),
                            subtitle: Text(data['username']),
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: kLightBlueColor,
                              radius: 25,
                              child: Icon(
                                Icons.local_phone_rounded,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'Phone Number',
                              style: kTextContent,
                            ),
                            subtitle: Text(data['phoneNumber']),
                          ),
                        ],
                      );
                    } //
                    else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future onOKPressed() async {
    String username = usernameController.text;
    String phone = phoneController.text;
    if (username.trim().isNotEmpty) {
      userRef.doc(auth.currentUser?.uid).update({'username': username});
      setState(() {});
      usernameController.clear();
    }
    if (phone.trim().isNotEmpty) {
      await verifyPhoneNumber();
    }
    Navigator.pop(context);
  }

  selectImageFromCamera() {
    selectImage(ImageSource.camera);
    Navigator.pop(context);
  }

  selectImageFromGallery() {
    selectImage(ImageSource.gallery);
    Navigator.pop(context);
  }

  selectImage(ImageSource imageSource) async {
    ImagePicker _imagePicker = ImagePicker();
    XFile _pickedImage =
        await _imagePicker.pickImage(source: imageSource) ?? XFile('-1');
    if (_pickedImage.path != '-1') {
      file = File(_pickedImage.path);

      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: file.path,
          aspectRatioPresets: Platform.isAndroid
              ? [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ]
              : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: const AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: const IOSUiSettings(
            title: 'Cropper',
          ));
      if (croppedFile != null) {
        file = croppedFile;
      }

      String url = await uploadImage();
      await auth.currentUser?.updatePhotoURL(url);
      await userRef.doc(auth.currentUser?.uid).update({'imageAddress': url});
      setState(() {});
    }
  }

  Future<String> uploadImage() async {
    try {
      setState(() {
        loading = true;
      });
      String path = file.path.split('/').last;
      TaskSnapshot snapshot =
          await storage.ref().child('users/profile/$path').putFile(file);
      String url = await snapshot.ref.getDownloadURL();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image Uploaded'),
        ),
      );
      return url;
    } catch (e) {
      print(e);
      return '-1';
    }
  }

  Future<DocumentSnapshot> loadData() async {
    return userRef.doc(auth.currentUser!.uid).get();
  }

  Future verifyPhoneNumber() async {
    String phone = phoneController.text;
    setState(() {
      loading = true;
    });
    if (!waitingForCode) {
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('********* complete ********');
          await auth.signInWithCredential(credential);
          print(auth);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
          print('********* error ***********');
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('********* code sent ********');
          myVerificationId = verificationId;
          print(verificationId);
          setState(() {
            waitingForCode = true;
            loading = false;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                    ),
                  ),
                  TextButton(
                    onPressed: onOKPressed,
                    child: const Text('send code'),
                  ),
                ],
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } //
    else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: myVerificationId, smsCode: codeController.text);
      await auth.currentUser?.updatePhoneNumber(credential);
      await userRef.doc(auth.currentUser?.uid).update({'phoneNumber': phone});
      phoneController.clear();
      codeController.clear();
      setState(() {
        myVerificationId = '-1';
        waitingForCode = false;
        loading = false;
      });
    }
  }
}
