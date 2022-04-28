import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String userId;
  late String name;
  late String username;
  late String phoneNumber;
  late Timestamp lastSignedIn;
  late Timestamp createdTime;
  late String imageAddress;
  late bool isActive;
  late bool isTyping;

  UserModel(this.userId,this.name, this.username, this.phoneNumber, this.lastSignedIn,
      this.createdTime,this.imageAddress, this.isActive,this.isTyping);

  UserModel.getFromDocument(DocumentSnapshot doc){
    Map data = doc.data() as Map;
    userId = data['userId'];
    name = data['name'];
    username = data['username'];
    phoneNumber = data['phoneNumber'];
    lastSignedIn = data['lastSignedIn'];
    createdTime = data['createdTime'];
    imageAddress = data['imageAddress'];
    isActive = data['isActive'];
    isTyping = data['isTyping'];
  }

  Map<String,dynamic> toMap()=>{
    'userId':userId,
    'name':name,
    'username':username,
    'phoneNumber':phoneNumber,
    'lastSignedIn':lastSignedIn,
    'createdTime':createdTime,
    'imageAddress':imageAddress,
    'isActive':isActive,
    'isTyping':isTyping,
  };

}

List<UserModel> users = [];