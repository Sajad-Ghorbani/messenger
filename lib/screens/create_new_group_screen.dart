import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/screens/chat_screen.dart';
import 'package:messenger/widgets/base_widget.dart';
import '../constants.dart';
import '../methods.dart';

class CreateNewGroupScreen extends StatefulWidget {
  const CreateNewGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateNewGroupScreenState createState() => _CreateNewGroupScreenState();
}

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  File file = File('-1');
  TextEditingController nameController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late CollectionReference usersRef;
  bool loading = false;
  List<String> memberList = [];
  String imageUrl = '-1';

  selectMember(bool selected, String member) {
    setState(() {
      if (selected) {
        memberList.add(member);
      } //
      else {
        memberList.remove(member);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    usersRef = FirebaseFirestore.instance.collection('Users');
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      appBar: AppBar(
        toolbarHeight: 65,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: Text(
          'Add New Group',
          style: kHeaderText,
        ),
        actions: [
          Container(
            child: IconButton(
              splashRadius: 1,
              onPressed: () {
                createGroup();
              },
              icon: const Icon(Icons.check),
              color: Colors.black,
            ),
            decoration: const BoxDecoration(
              color: kLightGreyColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: kBlueColor,
                      radius: 40,
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: file.path != '-1'
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: loading,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            shape: BoxShape.circle),
                      ),
                    ),
                    Visibility(
                      visible: loading,
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Please input group name',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder(
              stream: usersRef.orderBy('name').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map data = snapshot.data!.docs[index].data() as Map;
                      return Visibility(
                        visible: data['userId'] != auth.currentUser!.uid,
                        child: CheckboxListTile(
                          secondary: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: data['imageAddress'] == ''
                                          ? Image.asset(
                                              'assets/images/user-default.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              data['imageAddress'],
                                              fit: BoxFit.cover,
                                              height: 50,
                                              width: 50,
                                            ),
                                    )),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Visibility(
                                    visible: data['isActive'],
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          color: kGreenColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 3,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            data['name'],
                            style: kTextContent.copyWith(
                                fontFamily: 'Gilroy_semiBold'),
                          ),
                          subtitle: Text(
                            data['isActive']
                                ? 'online'
                                : kGetTime(data['lastSignedIn'].toDate()),
                            style: kHintText.copyWith(fontSize: 14),
                          ),
                          onChanged: (bool? value) {
                            selectMember(value!, data['userId']);
                            print(memberList);
                          },
                          value: memberList.contains(data['userId']),
                        ),
                      );
                    },
                  );
                } //
                else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  selectImage() async {
    ImagePicker _imagePicker = ImagePicker();
    XFile _pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery) ??
            XFile('-1');
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
      setState(() {});
      imageUrl = await uploadImage();
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

  void createGroup() async {
    String name = nameController.text.trim();
    if (name.isEmpty) {
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
              'Please input group name.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      );
    } //
    else {
      Map<String, dynamic> newChatRoom = {};
      newChatRoom['chatRoomName'] = name;
      newChatRoom['time'] = DateTime.now();
      if (imageUrl == '-1') {
        newChatRoom['imageAddress'] = '';
      } //
      else {
        newChatRoom['imageAddress'] = imageUrl;
      }
      memberList.add(auth.currentUser!.uid);
      newChatRoom['members'] = memberList;
      try {
        DocumentReference doc = await FirebaseFirestore.instance
            .collection('chatRooms')
            .add(newChatRoom);
        print(doc.id);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: doc.id,
              chatRoomName: name,
              imageAddress: newChatRoom['imageAddress'],
            ),
          ),
        );
      } catch (e) {
        print(e);
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
              child: Text(
                e.toString(),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        );
      }
    }
  }
}
