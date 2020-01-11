import 'package:OrangeChat/screens/login_screen.dart';
import 'package:OrangeChat/widgets/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:OrangeChat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:OrangeChat/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore = Firestore.instance;

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;

  SharedPreferences prefs;

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
                SizedBox(height: 48.0),
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
                  title: 'Register',
                  colour: Colors.orangeAccent,
                  onPressed: handleRegisteration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> handleRegisteration() async {
    // Login handler
    if (email == null || password == null) {
      return;
    }
    setState(() {
      showSpinner = true;
    });
    // Do Auth Here...
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        // Save to db
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('id', isEqualTo: newUser.user.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          _firestore.collection('users').document(newUser.user.uid).setData({
            'id': newUser.user.uid,
            'name': newUser.user.email,
            'imageUrl': newUser.user.photoUrl,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//            'chattingGroups': [ChatGroup().toJson()],
            'chattingGroups': [],
            'myContacts': [],
          });
        }

        // Write data to local
        final currentUser = _firestore
            .collection('users')
            .document(newUser.user.uid)
            .snapshots();

        await for (var field in currentUser) {
          final user = field.data;
          prefs = await SharedPreferences.getInstance();
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
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
      print(e);
      // User has been registered, so go to LoginScreen
      // Todo: Pass username and password to LoginScreen
      Navigator.pushNamed(context, LoginScreen.id);
    }
  }
}
