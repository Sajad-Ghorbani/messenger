import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/models/user.dart';
import 'package:messenger/screens/contact_screen.dart';
import 'package:messenger/screens/login_screen.dart';
import 'package:messenger/screens/private_chat_screen.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/widgets/base_widget.dart';

import '../methods.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference publicRef =
      FirebaseFirestore.instance.collection('chatRooms');
  CollectionReference privateRef =
      FirebaseFirestore.instance.collection('privateMessages');

  late AnimationController animationController;
  late Animation<double> animation;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.linear);
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        animationController.forward();
      } //
      else {
        animationController.reverse();
      }
    });
    animationController.forward();
  }

  Stream<List<DocumentSnapshot>> getChats() {
    return getUserDocument().asyncMap((docs) async {
      List<DocumentSnapshot> doc = await getPublicChats();
      return docs..addAll(doc);
    });
  }

  Stream<List<DocumentSnapshot>> getUserDocument() {
    Stream<QuerySnapshot> snapshot = privateRef.snapshots();
    return snapshot.map((docs) {
      List<DocumentSnapshot> list = [];
      for (var item in docs.docs) {
        Map data = item.data() as Map;
        if (data['chatRoomId'].toString().contains(auth.currentUser!.uid)) {
          list.add(item);
        }
      }
      return list;
    });
  }

  Future<List<DocumentSnapshot>> getPublicChats() async {
    QuerySnapshot snapshot = await publicRef.get();
    List<DocumentSnapshot> list = [];
    for (var item in snapshot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      if (data['members'].toList().contains(auth.currentUser!.uid)) {
        list.add(item);
      }
    }
    return list;
  }

  Stream<List<UserModel>> getUsersList() {
    Stream<QuerySnapshot> snapshot = usersRef.snapshots();
    return snapshot.map((doc) {
      List<UserModel> list = [];
      for (var item in doc.docs) {
        list.add(UserModel.getFromDocument(item));
      }
      users = list;
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await usersRef.doc(auth.currentUser!.uid).update({
          'isActive': false,
          'lastSignedIn': DateTime.now(),
        });
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        color: kBlueColor,
        backgroundColor: kLightGreyColor,
        child: BaseWidget(
          floatingActionButton: AnimatedSize(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            child: ScaleTransition(
              scale: animation,
              child: OpenContainer(
                closedBuilder: (context, action) => const SizedBox(
                  height: 55,
                  width: 55,
                  child: Center(
                    child: Icon(
                      Icons.message_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
                closedElevation: 6,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                closedColor: kLightGreyColor,
                transitionDuration: const Duration(milliseconds: 400),
                openBuilder: (context, action) => ContactScreen(),
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 80,
            title: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: auth.currentUser?.photoURL == null
                            ? Image.asset(
                                'assets/images/user-default.png',
                                fit: BoxFit.cover,
                              )
                            : FadeInImage(
                                placeholder: const AssetImage(
                                    'assets/images/user-default.png'),
                                image: NetworkImage(
                                  auth.currentUser?.photoURL ?? '',
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text('Tosegar', style: kHeaderText),
              ],
            ),
            actions: [
              Container(
                child: IconButton(
                  splashRadius: 1,
                  onPressed: () async {
                    await usersRef.doc(auth.currentUser!.uid).update({
                      'isActive': false,
                      'lastSignedIn': DateTime.now(),
                    });
                    await auth.signOut();
                    Navigator.popUntil(context, (route) => false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app_rounded),
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
          child: StreamBuilder(
              stream: getUsersList(),
              builder: (context, AsyncSnapshot<List<UserModel>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 50,
                        child: TextField(
                          onTap: () {},
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              filled: true,
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search',
                              hintStyle: kHintText),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: getChats(),
                          builder: (context,
                              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                            if (snapshot.hasData && snapshot.data!.isEmpty) {
                              return Column(
                                children: [
                                  const Spacer(),
                                  Text(
                                    'Get Started',
                                    style: kHeaderText,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Tap',
                                        style: kTextContent,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: const Icon(
                                          Icons.message,
                                          size: 18,
                                        ),
                                      ),
                                      Text(
                                        'to send a message.',
                                        style: kTextContent,
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              );
                            }
                            if (snapshot.hasData) {
                              snapshot.data!.sort((a, b) {
                                Map map2 = a.data() as Map;
                                Map map1 = b.data() as Map;
                                return map1['time'].compareTo(map2['time']);
                              });
                              return ListView(
                                physics: const BouncingScrollPhysics(),
                                controller: scrollController,
                                children: snapshot.data!.map((doc) {
                                  Map data = doc.data() as Map;
                                  String id = doc.id;
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
                                  if (auth.currentUser!.uid ==
                                      data['userSender']) {
                                    for (var item in users) {
                                      if (item.userId == data['userReceiver']) {
                                        user = item;
                                      }
                                    }
                                  } //
                                  else {
                                    for (var item in users) {
                                      if (item.userId == data['userSender']) {
                                        user = item;
                                      }
                                    }
                                  }
                                  bool isTyping =
                                      user.isTyping && data['userTyping'];
                                  return OpenContainer(
                                    closedElevation: 0,
                                    closedBuilder: (context, action) =>
                                        ListTile(
                                      leading: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFFF58529),
                                                        Color(0xFFFEDA77),
                                                        Color(0xFFDD2A7B),
                                                        Color(0xFF8134AF),
                                                        Color(0xFF515BD4),
                                                      ],
                                                      begin:
                                                          Alignment.bottomRight,
                                                      end: Alignment.topLeft),
                                                  shape: BoxShape.circle),
                                              child: CircleAvatar(
                                                radius: 29,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 25,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      child: avatar(user, data),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: user.isActive,
                                              child: Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: kGreenColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Visibility(
                                                visible:
                                                    getMinutes(user) != -1 &&
                                                        data['chatRoomName'] ==
                                                            null,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 3,
                                                      vertical: 1),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: kGreenColor,
                                                    border: Border.all(
                                                      width: 3,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${getMinutes(user)} m',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: Text(
                                        data['chatRoomName'] ?? user.name,
                                        style:
                                            kHeaderText.copyWith(fontSize: 18),
                                      ),
                                      subtitle: Text(isTyping
                                          ? 'is typing...'
                                          : data['lastMessage'] != null
                                              ? data['lastMessage']['text']
                                              : 'There are no messages'),
                                    ),
                                    openBuilder: (context, action) =>
                                        data['chatRoomName'] != null
                                            ? ChatScreen(
                                                chatRoomId: id,
                                                chatRoomName:
                                                    data['chatRoomName'],
                                                imageAddress:
                                                    data['imageAddress'],
                                              )
                                            : PrivateChatScreen(
                                                chatRoomId: id,
                                                otherUser: user.toMap(),
                                                lastSigned: kGetTime(
                                                  user.lastSignedIn.toDate(),
                                                ),
                                              ),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                  );
                                }).toList(),
                              );
                            } //
                            else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } //
                else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }

  int getMinutes(UserModel user) {
    int time = DateTime.now().difference(user.lastSignedIn.toDate()).inMinutes;
    if (time == 0) return -1;
    if (time != 0 && time < 60 && user.isActive == false) return time;
    return -1;
  }

  Widget avatar(UserModel user, Map data) {
    if (data['chatRoomName'] != null) {
      if (data['imageAddress'] == '') {
        return Container(
          color: kBlueColor,
          child: Center(
            child: Text(
              data['chatRoomName'].toString().toUpperCase().substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        );
      } //
      else {
        return Image.network(
          data['imageAddress'],
          fit: BoxFit.cover,
          height: 50,
          width: 50,
        );
      }
    } //
    else {
      if (user.imageAddress == '') {
        return Image.asset('assets/images/user-default.png');
      } //
      else {
        return Image.network(
          user.imageAddress,
          fit: BoxFit.cover,
          height: 50,
          width: 50,
        );
      }
    }
  }
}
