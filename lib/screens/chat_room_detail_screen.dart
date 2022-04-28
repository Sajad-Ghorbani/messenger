import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/models/user.dart';
import 'package:messenger/screens/contact_profile_screen.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/widgets/base_widget.dart';

import '../constants.dart';
import '../methods.dart';

class ChatRoomDetailScreen extends StatelessWidget {
  const ChatRoomDetailScreen({Key? key, required this.chatRoomId})
      : super(key: key);
  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      appBar: AppBar(
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
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatRooms')
              .doc(chatRoomId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              Map data = snapshot.data!.data() as Map;
              List memberList = data['members'];
              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: data['imageAddress'] == ''
                              ? Container(
                                  color: kBlueColor,
                                  child: Center(
                                    child: Text(
                                      data['chatRoomName']
                                          .toUpperCase()
                                          .substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                )
                              : Image.network(
                                  data['imageAddress'],
                                  fit: BoxFit.cover,
                                  height: 80,
                                  width: 80,
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['chatRoomName'],
                            style: kHeaderText,
                          ),
                          Text(
                            '${memberList.length} members',
                            style: kHintText.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: memberList.length,
                      itemBuilder: (context, index) {
                        UserModel user = UserModel(
                          '',
                          '',
                          '',
                          '',
                          Timestamp(0, 0),
                          Timestamp(0, 0),
                          '',
                          false,
                          false,
                        );
                        for (var item in users) {
                          if (item.userId == data['members'][index]) {
                            user = item;
                          }
                        }
                        return ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: user.imageAddress == ''
                                          ? Image.asset(
                                              'assets/images/user-default.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              user.imageAddress,
                                              fit: BoxFit.cover,
                                              height: 50,
                                              width: 50,
                                            ),
                                    )),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Visibility(
                                    visible: user.isActive,
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
                            user.name,
                            style: kTextContent.copyWith(
                                fontFamily: 'Gilroy_semiBold'),
                          ),
                          subtitle: Text(
                            user.isActive
                                ? 'online'
                                : kGetTime(user.lastSignedIn.toDate()),
                            style: kHintText.copyWith(fontSize: 14),
                          ),
                          onTap: () {
                            if (user.userId == auth.currentUser!.uid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            } //
                            else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactProfileScreen(
                                      user.toMap(),
                                      kGetTime(user.lastSignedIn.toDate())),
                                ),
                              );
                            }
                          },
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
}
