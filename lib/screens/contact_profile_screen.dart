import 'package:flutter/material.dart';
import 'package:messenger/widgets/base_widget.dart';

import '../constants.dart';

class ContactProfileScreen extends StatelessWidget {
  const ContactProfileScreen(this.user, this.lastSigned, {Key? key})
      : super(key: key);
  final String lastSigned;
  final Map user;

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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            color: Colors.black,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileImage(user),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'profile',
                    child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: user['imageAddress'] == ''
                              ? Image.asset(
                                  'assets/images/user-default.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  user['imageAddress'],
                                  fit: BoxFit.cover,
                                  height: 160,
                                  width: 160,
                                ),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  user['name'],
                  style: kHeaderText,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          decoration: const BoxDecoration(
                            color: kLightGreyColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.phone),
                        ),
                        Text(
                          'Audio',
                          style: kTextContent,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          decoration: const BoxDecoration(
                            color: kLightGreyColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.videocam_rounded),
                        ),
                        Text(
                          'Video',
                          style: kTextContent,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          decoration: const BoxDecoration(
                            color: kLightGreyColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.person),
                        ),
                        Text(
                          'Profile',
                          style: kTextContent,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          decoration: const BoxDecoration(
                            color: kLightGreyColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.doorbell_rounded),
                        ),
                        Text(
                          'Mute',
                          style: kTextContent,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Text(
            'Profile',
            style: kHintText,
          ),
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
            subtitle: Text(user['isActive'] ? 'online' : lastSigned),
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
            subtitle: Text(user['username']),
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
            subtitle: Text(user['phoneNumber']),
          ),
        ],
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage(this.user, {Key? key}) : super(key: key);
  final Map user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'profile',
          child: user['imageAddress'] != null
              ? Image.network(
                  user['imageAddress'],
                )
              : Image.asset('assets/images/user-default.png'),
        ),
      ),
    );
  }
}
