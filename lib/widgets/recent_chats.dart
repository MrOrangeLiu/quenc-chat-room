import 'package:intl/intl.dart';

import 'package:OrangeChat/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:OrangeChat/models/message_model.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:OrangeChat/models/chat_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class RecentChats extends StatefulWidget {
  String id;
  RecentChats({this.id});
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  User myself, peer;

  @override
  Widget build(BuildContext context) {
    if (widget.id != '') {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .where('groupChatIds', arrayContains: widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)));
          } else {
            final chatGroups = snapshot.data.documents;
//  Test Only
//            return Center(
//              child: Text(
//                'Hello World: ' +
//                    chatGroups.length.toString() +
//                    '  ' +
//                    widget.id.toString() +
//                    '  ' +
//                    chatGroups[0]['members'].toString(),
//                style: TextStyle(fontSize: 12.0),
//              ),
//            );

            return ListView.builder(
              itemCount: chatGroups.length,
              itemBuilder: (context, index) {
                final ChatGroup chat =
                    ChatGroup.fromDocumentSnapshot(chatGroups[index]);
                // Get myself from group's member list
                List<User> members = chat.members;
                for (var member in members) {
//                  print(member.id.toString() + " and " + widget.id.toString());
                  if (member.id == widget.id) {
                    myself = member;
//                    print('myself');
                  } else {
                    peer = member;
//                    print('peer');
                  }
                }

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChatScreen(
                        peer: peer,
                      ),
                    ),
                  ),
                  child: Container(
                      margin:
                          EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: peer.unread ? Color(0xFFFFEFEE) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(
                                  // Todo: If not exist than give it a default avatar
                                  peer.imageUrl,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    peer.name ?? 'User somebody',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.0),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: Text(
                                      chat.latestChat ?? ' ',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                DateFormat('hh:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(chat.latestChatCreatedAt))),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              myself.unread
                                  ? Container(
                                      width: 40.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(''),
                            ],
                          ),
                        ],
                      )),
                );
              },
            );
          }
        },
      );
    } else {
      return Container();
    }
  }
}
