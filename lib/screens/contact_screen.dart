import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/methods.dart';
import 'package:messenger/screens/create_new_group_screen.dart';
import 'package:messenger/screens/private_chat_screen.dart';
import 'package:messenger/widgets/base_widget.dart';

import '../constants.dart';

class ContactScreen extends StatelessWidget {
  ContactScreen({Key? key}) : super(key: key);
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');
  String chatRoomId = '';

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
          'Contacts',
          style: kHeaderText,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: usersRef.orderBy('name').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.add,
                      color: kBlueColor,
                      size: 30,
                    ),
                    title: Text(
                      'Add New Group',
                      style: kTextContent.copyWith(color: kBlueColor,fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNewGroupScreen(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map data = snapshot.data!.docs[index].data() as Map;
                        Timer(const Duration(), () async {
                          chatRoomId = await getChatRoomId(
                              auth.currentUser!.uid, data['userId']);
                        });
                        return OpenContainer(
                          closedBuilder: (context, action) {
                            return Visibility(
                              visible: data['userId'] != auth.currentUser!.uid,
                              child: ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.white,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
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
                                // onTap: () async {
                                //   chatRoomId = await getChatRoomId(
                                //       auth.currentUser!.uid, data['userId']);
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => PrivateChatScreen(
                                //         otherUser: data,
                                //         lastSigned:
                                //         kGetTime(data['lastSignedIn'].toDate()),
                                //         chatRoomId: chatRoomId,
                                //       ),
                                //     ),
                                //   );
                                // },
                              ),
                            );
                          },
                          openBuilder: (context, action) {

                            return PrivateChatScreen(
                              otherUser: data,
                              lastSigned:
                                  kGetTime(data['lastSignedIn'].toDate()),
                              chatRoomId: chatRoomId,
                            );
                          },
                          transitionDuration:
                          const Duration(milliseconds: 400),
                          closedElevation: 0,
                        );
                      },
                    ),
                  ),
                ],
              );
            } //
            else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<String> getChatRoomId(String currentUser, String contact) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('privateMessages')
        .doc('$currentUser*$contact')
        .get();
    if (snapshot.exists) {
      return '$currentUser*$contact';
    } //
    else {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('privateMessages')
          .doc('$contact*$currentUser')
          .get();
      if (snapshot.exists) {
        return '$contact*$currentUser';
      } //
      else {
        return '$currentUser*$contact';
      }
    }
  }
}
