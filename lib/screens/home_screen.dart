import 'dart:async';
import 'dart:io';

import 'package:OrangeChat/widgets/toptapbar_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrangeChat/widgets/recent_chats.dart';
import 'package:OrangeChat/widgets/my_contacts.dart';
import 'package:OrangeChat/screens/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  SharedPreferences prefs;
  HomeScreen({this.prefs});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _pageController = PageController(
    initialPage: 0,
  );

  String messageText;
  int currentPageIndex = 0;

  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  SharedPreferences prefs;
  String uid;
  String name;
  String imageUrl;

  @override
  void initState() {
    super.initState();
    authCurrentUser();
  }

  authCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);

        prefs = await SharedPreferences.getInstance();

        // Write data to local
        if (loggedInUser.uid != prefs.getString('id')) {
          // Exit
          handleSignOut();
//          Navigator.pushAndRemoveUntil(
//            context,
//            MaterialPageRoute(builder: (context) => WelcomeScreen()),
//            ModalRoute.withName(HomeScreen.id),
//          );
        } else {
          // Doesn't work for some
          await assignValues();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> assignValues() async {
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('id');
    name = prefs.getString('name');
    imageUrl = prefs.getString('imageUrl');
    setState(() {});
    return Future.value(null);
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.pushNamed(context, SettingScreen.id);
    }
  }

  void handleSignOut() {
    _auth.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferences prefs = ModalRoute.of(context).settings.arguments;
//    print('build has: uid: $uid, name: $name, imageUrl: $imageUrl');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 30.0,
          color: Colors.white,
          onPressed: () {},
        ),
        title: Center(
          child: Text(
            'Chats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        choice.icon,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        choice.title,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                );
              }).toList();
            },
          ),
//          IconButton(
//            color: Colors.white,
//            icon: Icon(Icons.close),
//            onPressed: () {
//              _auth.signOut();
//              Navigator.pop(context);
//            },
//          ),
        ],
      ),
      body: WillPopScope(
        child: Column(
          children: <Widget>[
            TopTapBarSelector(
              currentIndex: currentPageIndex,
              onTap: (index) => this.onTap(index),
            ),
            Expanded(
                child: PageView(
              controller: _pageController,
              onPageChanged: onPageChange,
              children: <Widget>[
                Container(
                  // Messages Container
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: RecentChats(
                        id: prefs.getString('id') ??
                            ''), // The builder will build twice, so the first time passing an empty value
                  ),
                ),
                Container(
                  // Contacts Container
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: MyContacts(),
                  ),
                ),
              ],
            )),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  void onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChange(int index) {
    setState(() {
      if (currentPageIndex != index) {
        currentPageIndex = index;
      }
    });
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(
        false); // Say, OK, Stop going back and I'm gonna take it from here by myself
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.only(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
            ),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                width: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 200,
                padding: EdgeInsets.only(left: 10.0),
                color: Colors.white,
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.cancel,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'CANCEL',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: 200,
                padding: EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'YES',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        })) {
      case (0):
        break;
      case (1):
        exit(0);
        break;
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}
