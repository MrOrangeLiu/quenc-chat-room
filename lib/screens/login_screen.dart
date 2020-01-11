import 'package:flutter/material.dart';
import 'package:OrangeChat/widgets/rounded_button.dart';
import 'package:OrangeChat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:OrangeChat/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore = Firestore.instance;

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email, password;
  SharedPreferences prefs;

  Future<Null> handleLogIn() async {
    prefs = await SharedPreferences.getInstance();

    if (email == null || password == null) {
      return;
    }

    setState(() {
      showSpinner = true;
    });

    // Login Here...
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        // Write data to local
        final currentUser =
            _firestore.collection('users').document(user.user.uid).snapshots();

        await for (var field in currentUser) {
          final user = field.data;
          prefs = await SharedPreferences.getInstance();
          await prefs.setString('id', user['id']);
          await prefs.setString('name', user['name']);
          await prefs.setString('imageUrl', user['imageUrl']);
          break;
        }

        // Login unsuccessfully
        setState(() {
          showSpinner = false;
        });

        // Go to HomeScreen
        Navigator.pushNamed(context, HomeScreen.id, arguments: prefs);
      }
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value.trim();
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Your Email'),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value.trim();
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Your Password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Log In',
                  colour: Colors.orangeAccent,
                  onPressed: handleLogIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
