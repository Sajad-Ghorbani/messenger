import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:messenger/screens/contact_profile_screen.dart';
import 'package:messenger/widgets/base_widget.dart';

import '../constants.dart';

class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen(
      {Key? key,
      required this.otherUser,
      required this.lastSigned,
      required this.chatRoomId})
      : super(key: key);
  final Map otherUser;
  final String lastSigned;
  final String chatRoomId;

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference messagesRef;
  late CollectionReference userRef;
  final ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  bool isEditing = false;
  String editingText = '';
  String messageID = '-1';
  String userReply = '';
  String replyText = '';
  bool isReply = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messagesRef = fireStore.collection('privateMessages');
    userRef = fireStore.collection('Users');
  }

  Stream<Map<String, dynamic>> getUserTyping() {
    return userRef
        .doc(widget.otherUser['userId'])
        .snapshots()
        .asyncMap((doc) async {
      DocumentSnapshot messageDoc =
          await messagesRef.doc(widget.chatRoomId).get();
      Map<String, dynamic> userMap = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> messageMap = {};
      if (messageDoc.exists) {
        messageMap = messageDoc.data() as Map<String, dynamic>;
      }
      return userMap..addAll(messageMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ContactProfileScreen(widget.otherUser, widget.lastSigned),
              ),
            );
          },
          child: StreamBuilder(
              stream: getUserTyping(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  Map user = snapshot.data!;
                  return Row(
                    children: [
                      CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: user['imageAddress'] == ''
                                ? Image.asset(
                                    'assets/images/user-default.png',
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    user['imageAddress'],
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                  ),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: kHeaderText.copyWith(fontSize: 20),
                          ),
                          Text(
                            user['isTyping'] && user['userTyping']
                                ? 'is typing...'
                                : user['isActive']
                                    ? 'online'
                                    : widget.lastSigned,
                            style: kHintText.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  );
                } //
                else {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.otherUser['imageAddress'] == ''
                              ? Image.asset(
                                  'assets/images/user-default.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  widget.otherUser['imageAddress'],
                                  fit: BoxFit.cover,
                                  height: 40,
                                  width: 40,
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.otherUser['name'],
                        style: kHeaderText.copyWith(fontSize: 20),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: messagesRef
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: widget.otherUser['imageAddress'] == ''
                                    ? Image.asset(
                                        'assets/images/user-default.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.otherUser['imageAddress'],
                                        fit: BoxFit.cover,
                                        height: 160,
                                        width: 160,
                                      ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.otherUser['name'],
                            style: kHeaderText,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactProfileScreen(
                                      widget.otherUser, widget.lastSigned),
                                ),
                              );
                            },
                            child: Text(
                              'view profile',
                              style: kTextContent,
                            ),
                          )
                        ],
                      );
                    } //
                    else {
                      return ListView(
                        controller: _scrollController,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        children: snapshot.data!.docs.map((doc) {
                          Map data = doc.data() as Map;
                          bool isMe = auth.currentUser!.uid == data['sender'];
                          String id = doc.id;
                          String time = data['time'];
                          return GestureDetector(
                            onTap: () {
                              onMessageTapped(id, data);
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.76,
                              child: ChatBubble(
                                clipper: ChatBubbleClipper5(
                                  type: isMe
                                      ? BubbleType.sendBubble
                                      : BubbleType.receiverBubble,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: data['replyText'] != '',
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                              gradient: LinearGradient(
                                                colors: isMe
                                                    ? [
                                                        const Color(0xFFA7D6FC),
                                                        const Color(0xFFD8EBFF),
                                                      ]
                                                    : [
                                                        kLightGreyColor,
                                                        Colors.white,
                                                      ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['replyUser'],
                                                  style: const TextStyle(
                                                      color: kBlackColor,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  data['replyText'],
                                                  style: const TextStyle(
                                                      color: kBlackColor,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          data['text'],
                                          style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          data['editing'],
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                alignment: isMe
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                margin: EdgeInsets.only(
                                  top: 10,
                                  right: !isMe ? 20 : 0,
                                  left: isMe ? 20 : 0,
                                ),
                                backGroundColor: isMe ? kBlueColor : kGreyColor,
                              ),
                            ),
                          );
                        }).toList(),
                        // return Container();
                      );
                    }
                  } //
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: isReply,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          userReply,
                          style: kTextContent.copyWith(
                              fontSize: 16, color: kBlueColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              replyText.length > 36
                                  ? '${replyText.substring(0, 35)} ...'
                                  : replyText,
                              style: kTextContent.copyWith(fontSize: 16),
                            ),
                            IconButton(
                              onPressed: () {
                                reset();
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.redAccent,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isEditing,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editingText.length > 36
                              ? '${editingText.substring(0, 35)} ...'
                              : editingText,
                          style: kTextContent.copyWith(fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            reset();
                          },
                          icon: const Icon(Icons.close),
                          color: Colors.redAccent,
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (value) async {
                          await messagesRef
                              .doc(widget.chatRoomId)
                              .get()
                              .then((doc) {
                            if (doc.exists) {
                              userRef
                                  .doc(auth.currentUser!.uid)
                                  .update({'isTyping': true});
                              messagesRef
                                  .doc(widget.chatRoomId)
                                  .update({'userTyping': true});
                              Timer(const Duration(seconds: 4), () {
                                userRef
                                    .doc(auth.currentUser!.uid)
                                    .update({'isTyping': false});
                                messagesRef
                                    .doc(widget.chatRoomId)
                                    .update({'userTyping': false});
                              });
                            }
                          });
                        },
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 20),
                          filled: true,
                          fillColor: kGreyColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                          isEditing ? Icons.check_circle_rounded : Icons.send),
                      color: kBlueColor,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  onMessageTapped(String id, Map data) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      width: 300,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              onCopyPressed(data);
            },
            leading: const Icon(
              Icons.copy_rounded,
              color: Colors.black,
            ),
            title: Text(
              'Copy',
              style: kTextContent,
            ),
          ),
          ListTile(
            onTap: () {
              onReplyPressed(id, data);
            },
            leading: const Icon(
              Icons.reply_rounded,
              color: Colors.black,
            ),
            title: Text(
              'Reply',
              style: kTextContent,
            ),
          ),
          Visibility(
            visible: auth.currentUser!.uid == data['sender'],
            child: ListTile(
              onTap: () {
                onEditPressed(id, data);
              },
              leading: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
              title: Text(
                'Edit',
                style: kTextContent,
              ),
            ),
          ),
          Visibility(
            visible: auth.currentUser!.uid == data['sender'],
            child: ListTile(
              onTap: () {
                onDeletePressed(id);
              },
              leading: const Icon(
                Icons.delete,
                color: Colors.black,
              ),
              title: Text(
                'Delete',
                style: kTextContent,
              ),
            ),
          ),
        ],
      ),
    ).show();
  }

  void sendMessage() async {
    String text = controller.text.trim();
    Map<String, dynamic> newMessage = {};
    newMessage['text'] = text;
    newMessage['dateTime'] = DateTime.now();
    newMessage['time'] = DateTime.now().toString().substring(11, 16);
    newMessage['sender'] = auth.currentUser!.uid;
    newMessage['senderName'] = auth.currentUser!.displayName;
    newMessage['senderImage'] = auth.currentUser!.photoURL;
    newMessage['editing'] = '';
    newMessage['replyText'] = '';
    newMessage['replyUser'] = '';
    if (text.isEmpty) {
      //pass
    } //
    else {
      if (isEditing) {
        if (messageID != '-1') {
          messagesRef
              .doc(widget.chatRoomId)
              .collection('chats')
              .doc(messageID)
              .update({
            'editing': 'Edited',
            'text': text,
          });
          reset();
        }
      } //
      else {
        setState(() {
          if (isReply) {
            newMessage['replyText'] = replyText;
            newMessage['replyUser'] = userReply;
          }
          messagesRef.doc(widget.chatRoomId).set({
            'chatRoomId': widget.chatRoomId,
            'userSender': auth.currentUser!.uid,
            'userReceiver': widget.otherUser['userId'],
            'time': DateTime.now(),
            'userTyping': false,
            'lastMessage': newMessage,
            'user': 'new user'
          });
          messagesRef
              .doc(widget.chatRoomId)
              .collection('chats')
              .add(newMessage);
          reset();
        });
      }
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInQuad);
      });
    }
  }

  void onEditPressed(String id, Map data) {
    Navigator.pop(context);
    controller.text = data['text'];
    setState(() {
      isReply = false;
      isEditing = true;
      editingText = data['text'];
      messageID = id;
    });
  }

  void onDeletePressed(String id) async {
    await messagesRef
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(id)
        .delete();
    Navigator.pop(context);
    await messagesRef
        .doc(widget.chatRoomId)
        .collection('chats')
        .get()
        .then((doc) {
      if (doc.docs.isEmpty) {
        messagesRef.doc(widget.chatRoomId).delete();
      }
    });
  }

  void reset() {
    setState(() {
      controller.clear();
      isEditing = false;
      isReply = false;
      editingText = '';
      messageID = '-1';
    });
  }

  void onReplyPressed(String id, Map data) {
    Navigator.pop(context);
    setState(() {
      isEditing = false;
      isReply = true;
      replyText = data['text'];
      messageID = id;
      userReply = data['senderName'];
    });
  }

  void onCopyPressed(Map data) {
    Navigator.pop(context);
    Clipboard.setData(ClipboardData(text:data['text'])).then((_){
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
              'The text copied to clipboard.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      );
    });
  }
}
