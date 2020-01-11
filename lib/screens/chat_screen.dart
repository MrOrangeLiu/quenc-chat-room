import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:OrangeChat/models/message_model.dart';

import 'package:OrangeChat/screens/full_photo_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

final _firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  User peer;
  ChatScreen({this.peer});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText = ''; // Save typed in text
  String groupChatId;
  SharedPreferences prefs;
  User myself;
  bool showSpinner = false;
  File imageFile;
  String photoUrl;

  @override
  void initState() {
    super.initState();

    photoUrl = '';
    getGroupId();
    //Set my personal unread in GroupChatId Document to false
  }

  // The way to create chatGroupId
  void getGroupId() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('id') ?? '';
      final peerId = widget.peer.id;
      if (id.hashCode <= peerId.hashCode) {
        groupChatId = '$id-$peerId';
      } else {
        groupChatId = '$peerId-$id';
      }

      setState(() {});

      await checkGroupId();
    } catch (e) {
      print(e);
    }
  }

  // Create a chatGroup when first open the chat room with the peer
  Future<Null> checkGroupId() async {
    final QuerySnapshot result = await _firestore
        .collection('messages')
        .where('groupChatId', isEqualTo: groupChatId)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    myself = User.toObject(prefs.getString('id'), prefs.getString('name'),
        prefs.getString('imageUrl'));
    if (documents.length == 0) {
      // Create a chat group here...
      final membersList = User.combineToMap([widget.peer, myself]);
      _firestore.collection('messages').document(groupChatId).setData({
        'groupChatId': groupChatId,
        'groupChatIds': [widget.peer.id, myself.id],
        'groupName': 'Group Name - Can be edited',
        'latestChat':
            '', // Don't have to set this here, this field can be added to DB if update it later on
        'latestChatCreatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'imageUrl': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'members': membersList,
      });
    } else {
      // Set my unread to false cause I have read as I'm in this page
      _firestore.collection('messages').document(groupChatId).updateData({
        'members.${myself.id}.unread': false,
      });
      print('Group has bee established, please chat...');
    }
  }

  void onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content != null && content.trim() != '') {
      messageTextController.clear();

      try {
        // Update ChatGroup information
        _firestore.collection('messages').document(groupChatId).updateData({
          'latestChat': content,
          'latestChatCreatedAt':
              DateTime.now().millisecondsSinceEpoch.toString(),
          'unread': true,
        });

        // Set peer's unread to true cause I have read as I'm in this page
        _firestore.collection('messages').document(groupChatId).updateData({
          'members.${widget.peer.id}.unread': true,
        });

        var documentReference = _firestore
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .document(DateTime.now().millisecondsSinceEpoch.toString());

        _firestore.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'sender': User().toJson(prefs.getString('id'),
                  prefs.getString('name'), prefs.getString('imageUrl')),
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'type': type,
              'isLiked': false,
              'unread': true,
            },
          );
        });
      } catch (e) {
        print(e);
      }
    } else {
      // Flutter Toast?
      return;
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        this.showSpinner = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      photoUrl = downloadUrl;
      setState(() {
        this.showSpinner = false;
        onSendMessage(photoUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        this.showSpinner = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  _buildMessage(Message message, bool isMe) {
    final Padding msg = Padding(
      padding: isMe
          ? EdgeInsets.only(
              left: 70.0,
              right: 8.0,
              top: 8.0,
              bottom: 8.0,
            )
          : EdgeInsets.only(
              left: 8.0,
              top: 8.0,
              bottom: 8.0,
            ),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              !isMe
                  ? Container(
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundImage: AssetImage(message.sender.imageUrl),
                      ),
                    )
                  : Text(''),
              SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(message.time))),
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  message.type == 0
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhotoScreen(
                                          url: message.content)));
                            },
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: message.content,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ],
              ),
              isMe
                  ? Container(
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundImage: AssetImage(message.sender.imageUrl),
                      ),
                    )
                  : Text(''),
            ],
          ),
        ),
      ),
    );

    if (isMe) {
      return msg;
    }

    return Row(
      children: <Widget>[
        msg,
// Todo: Uncommand this and implement like function
//        IconButton(
//          icon: message.isLiked
//              ? Icon(Icons.favorite)
//              : Icon(Icons.favorite_border),
//          iconSize: 30.0,
//          color:
//              message.isLiked ? Theme.of(context).primaryColor : Colors.black,
//          onPressed: () {},
//        ),
      ],
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: getImage, // Photo picker
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: messageTextController,
              onChanged: (value) {
                setState(() {
                  messageText = value;
                });
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {});
              onSendMessage(messageText, 0);
            }, // Send message
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.peer;
    if (ModalRoute.of(context).settings.arguments != null) {
      user = ModalRoute.of(context).settings.arguments;
    }

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Center(
            child: Text(
              user.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('messages')
                          .document(groupChatId)
                          .collection(groupChatId)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor)));
                        } else {
                          final messages = snapshot.data.documents;

                          // Set my unread to false here cause I don't want to go back to previous page and see there is a new message
                          if (myself != null) {
                            _firestore
                                .collection('messages')
                                .document(groupChatId)
                                .updateData({
                              'members.${myself.id}.unread': false,
                            });
                          }

                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              final message = Message.toObject(messages[index]);
                              final bool isMe =
                                  message.sender.id == prefs.getString('id');
                              return _buildMessage(message, isMe);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }
}
