import 'dart:convert';
import 'package:OrangeChat/models/chat_model.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGroup {
  List<User> members;
  String createdAt;
  String groupChatId;
  String groupName;
  String imageUrl;
  String latestChat;
  String latestChatCreatedAt;

  ChatGroup({
    this.members,
    this.createdAt,
    this.groupChatId,
    this.groupName,
    this.imageUrl,
    this.latestChat,
    this.latestChatCreatedAt,
  });

  ChatGroup.fromJson(Map data) {
    this.members = data['members'];
    this.createdAt = data['time'];
    this.groupChatId = data['id'];
    this.groupName = data['groupName'];
    this.imageUrl = data['imageUrl'];
    this.latestChat = data['latestChat'];
    this.latestChatCreatedAt = data['latestChatCreatedAt'];
  }

  ChatGroup.fromDocumentSnapshot(DocumentSnapshot groupChat) {
    this.members = getAllMembersFromMap(groupChat['members']);
    this.createdAt = groupChat['timestamp'];
    this.groupChatId = groupChat['groupChatId'];
    this.groupName = groupChat['groupName'];
    this.imageUrl = groupChat['imageUrl'];
    this.latestChat = groupChat['latestChat'];
    this.latestChatCreatedAt = groupChat['latestChatCreatedAt'];
  }

  List<User> getAllMembersFromMap(Map<dynamic, dynamic> data) {
    print(data.toString());
    List<User> list = [];
    data.forEach((key, value) {
      list.add(User.forGroup(
        key,
        value['name'],
        value['imageUrl'],
        value['unread'],
      ));
//      print(value['name'] + value['imageUrl'] + value['unread'].toString());
    });
    return list;
  }

//  Map<String, dynamic> toJson() {
//    return {
//      "members": members,
//      "time": time,
//      "id": id,
//      "groupName": groupName,
//      "imageUrl": imageUrl,
//    };
//  }
}
