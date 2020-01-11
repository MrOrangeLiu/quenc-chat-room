import 'package:OrangeChat/screens/login_screen.dart';
import 'package:OrangeChat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:OrangeChat/widgets/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:OrangeChat/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseUser loggedInUser;
final _firestore = Firestore.instance;

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();

    isLoggedIn();

    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    animation =
        ColorTween(begin: Colors.orange, end: Colors.white).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
//      print(animation.value);
    });
  }

  void isLoggedIn() async {
    setState(() {
      showSpinner = true;
    });

    prefs = await SharedPreferences.getInstance();

    loggedInUser = await _auth.currentUser();
    if (loggedInUser != null) {
      // Write data to local
      final currentUser =
          _firestore.collection('users').document(loggedInUser.uid).snapshots();

      await for (var field in currentUser) {
        final user = field.data;
        await prefs.setString('id', user['id']);
        await prefs.setString('name', user['name']);
        await prefs.setString('imageUrl', user['imageUrl']);
        break;
      }
      Navigator.pushNamed(context, HomeScreen.id, arguments: prefs);
    }

    setState(() {
      showSpinner = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 55.0,
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    text: ['Orange Chat'],
                    textStyle: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.0),
              RoundedButton(
                title: 'Log In',
                colour: Colors.orange,
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              RoundedButton(
                title: 'Register',
                colour: Colors.orangeAccent,
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
