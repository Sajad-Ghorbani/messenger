import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/methods.dart';
import 'package:messenger/models/user.dart';
import 'package:messenger/screens/chat_room_detail_screen.dart';
import 'package:messenger/screens/contact_profile_screen.dart';
import 'package:messenger/widgets/base_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {Key? key,
      required this.chatRoomId,
      required this.chatRoomName,
      required this.imageAddress})
      : super(key: key);
  final String chatRoomId, chatRoomName, imageAddress;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late CollectionReference messagesRef;
  late CollectionReference usersRef;
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
    messagesRef = fireStore.collection('chatRooms');
    usersRef = fireStore.collection('Users');
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
                  builder: (context) => ChatRoomDetailScreen(
                    chatRoomId: widget.chatRoomId,
                  ),
                ));
          },
          child: StreamBuilder(
              stream: messagesRef.doc(widget.chatRoomId).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  Map data = snapshot.data!.data() as Map;
                  List memberList = data['members'];
                  return Row(
                    children: [
                      CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
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
                            data['chatRoomName'],
                            style: kHeaderText.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${memberList.length} members',
                            style: kHintText.copyWith(
                              fontSize: 14,
                            ),
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
                            child: widget.imageAddress == ''
                                ? Container(
                                    color: kBlueColor,
                                    child: Center(
                                      child: Text(
                                        widget.chatRoomName
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
                                    widget.imageAddress,
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
                            widget.chatRoomName,
                            style: kHeaderText.copyWith(fontSize: 20),
                          ),
                        ],
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
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: widget.imageAddress == ''
                                  ? Container(
                                      color: kBlueColor,
                                      child: Center(
                                        child: Text(
                                          widget.chatRoomName
                                              .toUpperCase()
                                              .substring(0, 1),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 60,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      widget.imageAddress,
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.chatRoomName,
                            style: kHeaderText,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'No Message here...',
                            style: kHintText,
                          ),
                        ],
                      );
                    } //
                    else {
                      return ListView(
                        controller: _scrollController,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        children: snapshot.data!.docs.map(
                          (doc) {
                            Map data = doc.data() as Map;
                            bool isMe = data['sender'] == auth.currentUser!.uid;
                            String id = doc.id;
                            String time = data['time'].toString();
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
                              if (item.userId == data['sender']) {
                                user = item;
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: !isMe,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ContactProfileScreen(
                                            user.toMap(),
                                            kGetTime(
                                              user.lastSignedIn.toDate(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: user.imageAddress != ''
                                              ? FadeInImage(
                                                  fit: BoxFit.cover,
                                                  placeholder: const AssetImage(
                                                      'assets/images/user-default.png'),
                                                  image: NetworkImage(
                                                    user.imageAddress,
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/user-default.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    onMessageTapped(id, data);
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.76,
                                    child: ChatBubble(
                                      clipper: ChatBubbleClipper5(
                                        type: isMe
                                            ? BubbleType.sendBubble
                                            : BubbleType.receiverBubble,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: !isMe,
                                                child: Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    data['replyText'] != '',
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                      top: Radius.circular(10),
                                                    ),
                                                    gradient: LinearGradient(
                                                      colors: isMe
                                                          ? [
                                                              const Color(
                                                                  0xFFA7D6FC),
                                                              const Color(
                                                                  0xFFD8EBFF),
                                                            ]
                                                          : [
                                                              kLightGreyColor,
                                                              Colors.white,
                                                            ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                style: kTextContent.copyWith(
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
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
                                                data['Edited'],
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
                                      backGroundColor:
                                          isMe ? kBlueColor : kGreyColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
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
                              replyText,
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
                          editingText,
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
                              usersRef
                                  .doc(auth.currentUser!.uid)
                                  .update({'isTyping': true});
                              messagesRef
                                  .doc(widget.chatRoomId)
                                  .update({'userTyping': true});
                              Timer(const Duration(seconds: 4), () {
                                usersRef
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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

  void sendMessage() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInQuad);
    String text = controller.text.trim();
    Map<String, dynamic> newMessage = {};
    newMessage['text'] = text;
    newMessage['dateTime'] = DateTime.now();
    newMessage['time'] = DateTime.now().toString().substring(11, 16);
    newMessage['sender'] = auth.currentUser!.uid;
    newMessage['senderName'] = auth.currentUser!.displayName;
    newMessage['senderImage'] = auth.currentUser!.photoURL;
    newMessage['Edited'] = '';
    newMessage['replyText'] = '';
    newMessage['replyUser'] = '';
    if (text.isNotEmpty) {
      if (isEditing) {
        if (messageID != '-1') {
          messagesRef.doc(messageID).update({'Edited': 'Edited', 'text': text});
          reset();
        }
      } //
      else {
        if (isReply) {
          newMessage['replyText'] = replyText;
          newMessage['replyUser'] = userReply;
        }
        messagesRef.doc(widget.chatRoomId).update({
          'userSender': auth.currentUser!.uid,
          'time': DateTime.now(),
          'userTyping': false,
          'lastMessage': newMessage
        });
        messagesRef
            .doc(widget.chatRoomId)
            .collection('chats')
            .add(newMessage)
            .then((value) => print(value));
        reset();
      }
    }
  }

  void onEditPressed(String id, data) {
    Navigator.pop(context);
    controller.text = data['text'];
    setState(() {
      isReply = false;
      isEditing = true;
      editingText = data['text'];
      messageID = id;
    });
  }

  void onDeletePressed(String id) {
    messagesRef.doc(id).delete();
    Navigator.pop(context);
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
    Clipboard.setData(ClipboardData(text: data['text'])).then((_) {
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
