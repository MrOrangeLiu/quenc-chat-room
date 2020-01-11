import 'package:flutter/material.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:OrangeChat/widgets/contact_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class MyContacts extends StatefulWidget {
  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        } else {
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                final favorite_user = snapshot.data.documents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ContactDetail(
                            user: User.toObject(
                                favorite_user['id'],
                                favorite_user['name'],
                                favorite_user['imageUrl'])),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF7A9BEE),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Hero(
                              tag: favorite_user['imageUrl'],
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundImage:
                                    AssetImage(favorite_user['imageUrl']),
                              ),
                            ),
                            SizedBox(width: 30.0),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.45, // In case of a user's name is too long
                              child: Text(
                                favorite_user['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        }
      },
    );
  }
}
