import 'package:OrangeChat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:OrangeChat/screens/home_screen.dart';

class ContactDetail extends StatefulWidget {
  final User user;

  ContactDetail({this.user});

  @override
  _ContactDetailState createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7A9BEE),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 82.0,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
          ),
          Positioned(
            top: 75.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45.5),
                  topRight: Radius.circular(45.5),
                ),
                color: Colors.white,
              ),
              height: MediaQuery.of(context).size.height - 100.0,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Positioned(
            top: 30.0,
            left: (MediaQuery.of(context).size.width / 2) - 100.0,
            child: Hero(
              tag: widget.user.imageUrl,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  image: DecorationImage(
                    image: AssetImage(widget.user.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 200.0,
                width: 200.0,
              ),
            ),
          ),
          Positioned(
            top: 260.0,
            left: 25.0,
            right: 25.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
//                  color: Colors.red,
                  child: Text(widget.user.name,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
//                            Navigator.popUntil(context,
//                                (r) => r.settings.name == HomeScreen.id);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => ChatScreen(
                                        peer: widget.user,
                                      )),
                              ModalRoute.withName(HomeScreen.id),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.message,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Message',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
